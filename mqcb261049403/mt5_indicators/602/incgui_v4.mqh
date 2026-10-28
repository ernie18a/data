//+------------------------------------------------------------------+
//|                                                    IncGUI_v4.mqh |
//|                                                          Integer |
//|                            https://www.mql5.com/ru/users/integer |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "https://www.mql5.com/ru/users/integer"
#property version   "4.00"

/*
   Arrangement of classes in the file:
   
   01. CGraphicObjectShell Class.
   02. Declaration of the CGraphicObjectShell class with name "g".
   03. CWorkPiece Class.
   04. Declaration of the CWorkPiece class with name "w".
   05. CColorSchemes Class.
   06. Declaration of the CColorSchemes class with name "ClrScheme".
   07. Control classes.  
         07.01. CInputBox Class (Input Box).
         07.02. CSpinInputBox Class (Spin Button Input Box). 
         07.03. CCheckBox Class (Checkbox). 
         07.04. CRadioGroup Class (Radio Button Group). 
         07.05. CVScrollBar Class (Vertical Scrollbar).  
         07.06. CHScrollBar Class (Horizontal Scrollbar).    
         07.07. CList Class (List). 
         07.08. CListMS Class (Multiple-Selection List).  
         07.09. CComBox Class (Drop-Down List).  
         07.10. CHMenu Class (Horizontal Menu). 
         07.11. CVMenu Class (Vertical Menu). 
         07.12. CHProgress Class (Horizontal Progress Bar). 
         07.13. CDialer Class (Dialer). 
         07.14. CDialerInputBox Class (Dialer with Input Box).  
         07.15. CTable Class (Table). 
         07.16. CFrame Class (Frame).    
         07.17. CButton Class (Button).
         07.18. CLabel Class (Multiline Caption).
         07.19. CCalendar class (calendar. Not used independently, used within CCalendarInputBox).
         07.20. CCalendarInputBox class (entering data).
   8. Classes for creation of forms.
         08.1. CFormBase Class (Base Class).
         08.2. CFormTemplate Subclass: public CFormBase (editable template for creation of a form).
*/

/*
   New in v4:
  
      CCalendar and CCalendarInputBox classes are added. CCalendar is not used independently, 
      used within CCalendarInputBox.
   
      Colors for CCalendar and CCalendarInputBox are added to CColorSchemes class.

/*
   New in v3:
      
      Classes for creation of forms added:

         CFormBase (Base Class).
         CFormTemplate: public CFormBase (editable template for creation of a form).       
         
      Control classes added:
      
         CFrame (frame identical to the frame created by the Frame method of CWorkPiece class).
         CButton (a regular button, object OBJ_BUTON)
         CLabel (caption; text is output in several lines whereby the lines are separated by \n)

      * * *

      CColorSchemes class is updated with colors for a form, frame, button and caption.  
      
      * * *
      
      An error in the Frame() method of CWorkPiece class has been fixed. A subwindow number for a rectangle label
      could not be set.
      
      * * *
      
      In CVMenu class, a response to clicking the graphical object "Label" has been fixed 
      which is used to display the tick symbol; accordingly, there have been changes 
      in operation of the LastClickedX(), LastClickedY() and LastClickedQuarter() methods.
      When clicking the captions they now return values as in case with text boxes.
   
      Similar corrections have been applied to CHMenu and corresponding changes made to operation of LastClickedX(),
      LastClickedY(), LastClickedQuarter() and LastClickedW() methods.
      
      CHMenu and CVMenu classes have been updated by adding LastClickedName1() and LastClickedName2() methods. 
      These methods return the names of graphical objects forming
      the last clicked menu item. LastClickedName1() returns
      the name of the text box, LastClickedName2() returns the name of the label for the tick symbol.
      
      CHMenu and CVMenu classes have been updated by adding SolvePosX() and SolvePosY() methods
      which are intended for calculating the coordinates of a graphical object displayed at the menu command.
      The width of the displayed object is transmitted to the SolvePosX() method and the height of the displayed object
      is transmitted to the SolvePosY() method. Now there is no more need to use LastClickedX(),
      LastClickedY(), LastClickedQuarter() and LastClickedW() methods. 
      
      ToggleNameAdd() and ToggleNamesClear() methods have been added to CVMenu. These methods allow to
      arrange for automatic hiding of the menu upon any chart event except for
      the events of the menu itself and objects whose names were added by the ToggleNameAdd() method. 
      When adding the name by the ToggleNameAdd() method, the control automatically switches
      to such operating mode (with automatic hiding). The ToggleNamesClear() method is used 
      to clear the name list whereby the control switches to the normal operating mode. 
      
      ToggleNameAdd(), LastClickedName1() and LastClickedName2() methods allow to arrange
      a two-level menu. For example, a click on a horizontal menu item should open
      the vertical menu. Upon the event of clicking a horizontal menu item, we,
      using the LastClickedName1() and LastClickedName2() methods get the object names of the horizontal menu
      item which are then transmitted to ToggleNameAdd() of the vertical menu. After displaying the vertical
      menu, it will respond to any chart event except for its own events and events of the objects 
      added using the ToggleNameAdd() method. Upon the event of clicking a vertical menu
      item, the actions corresponding to this item are executed and the menu gets hidden. Prior to the next
      display of the vertical menu, the list of toggle names should be cleared and filled again.

      * * *
      
      In CHMenu and CVMenu classes, the description of the Event() methods in html documentation has been corrected.
      
      * * *
      
      Selected() and SetSelected() methods of CListMS class have been fixed. A size check of the array of list items
      has been added. Otherwise it was impossible to use an empty list.

*/

/*
   New in v2:
   
      CGraphicObjectShell:
         A typing error in the ...Distance() method names corrected (it was spelled Distanse())
         Methods added: SetXYDistance(), SetXYSize().
   
      CInputBox:
         A typing error in the ValueString() method name corrected (it was spelled ValueStrind)).
         Methods added: SetReadOnly(), ReadOnly().
   
      CColorSchemes:
      
         The order in the Show() method modified. The schemes are now arranged vertically and the colors are arranged horizontally.
         Color schemes added: 
                                    GreenScheme,
                                    YellowBlackScheme,
                                    LimeBlackScheme,
                                    AquaBlackScheme.
      
      Control classes added:
      
            CSpinInputBox (Spin Button Input Box),
            CCheckBox (Checkbox),
            CRadioGroup (Radio Button Group),
            CVScrollBar (Vertical Scrollbar),
            CHScrollBar (Horizontal Scrollbar),
            CList (List),
            CListMS (Multiple-Selection List),
            CComBox (Drop-Down List),
            CHMenu (Horizontal Menu),
            CVMenu (Vertical Menu),
            CHProgress (Horizontal Progress Bar),
            CDialer (Dialer),
            CDialerInputBox (Dialer with Input Box),
            CTable (Table).
*/      

//+------------------------------------------------------------------+
//|                                                                  |
//|         CGraphicObjectShell CLASS                                |
//|                                                                  |
//+------------------------------------------------------------------+

/*!
	\brief   Graphical objects creation and management.
	
	\details The class consists of methods for creation of graphical objects, methods for setting and 
	         getting their properties and so forth. methods relating to graphical objects.
	         
	         Methods for creating graphical objects start with the word "Create"; all these 
	         methods have three parameters: name, subwindow, chart. 
	         
	         Methods for setting the properties start with the word "Set". Methods for setting and getting 
	         the properties are represented in three options: 1) without parameters, 2) with one parameter 
	         (object name, 3) with two parameters (name, chart).
	         
	         Option 1 is used for handling graphical objects attached to the class. 
	         A graphical object can be attached to the class upon its creation by any of the 
	         Create...() methods or by the Attach() method. Option 2 is intended for 
	         handling graphical objects located in the "custom" chart, option 3 - for the ones 
	         located in any chart.
	         
   \remark	The class has already been declared in the file with name "g".
*/

class CGraphicObjectShell{
   protected:
      string m_name;
      long m_id;
   public:   
      /*
         Order of methods:
      
         1. Basic methods.
         2. Creation.
         
         3. Getting the attached object properties.
         4. Setting the attached object properties.
         
         5. Getting the properties by the object name.
         6. Setting the properties by the object name.
         
         7. Getting the properties by the chart identifier and object name.
         8. Setting the properties by the chart identifier and object name.
         
         9. Other methods.
      */
      
      //+------------------------------------------------------------------+
      //|   Basic methods                                                       |
      //+------------------------------------------------------------------+
   
		/*!	
			Graphical object attachment.
		 	\param		string aName - name of the attached graphical object,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is located.
		*/
      void Attach(string aName,long aChartID=0){
         m_name=aName;
         m_id=aChartID;
      }
      
		/*!	
			Getting the name of the attached graphical object.
         \return  Name of the attached graphical object.
		*/		
      string Name(){return(m_name);}   
      
		/*!	
			Getting the attached graphical object chart identifier.
         \return  Graphical object chart identifier.
		*/      
      long ChartID(){return(m_id);}
      
      //+------------------------------------------------------------------+
      //|   Creation                                                       |
      //+------------------------------------------------------------------+      
		
		/*!	
			Creation of the "Vertical Line" OBJ_VLINE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateVLine           (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_VLINE,             aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Horizontal Line" OBJ_HLINE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/        
      void CreateHLine           (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_HLINE,             aSubWindow,0,0);Attach(aName,aChartID);}

		/*!	
			Creation of the "Trendline" OBJ_TREND object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/       
      void CreateTrend           (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_TREND,             aSubWindow,0,0);Attach(aName,aChartID);}

		/*!	
			Creation of the "Trend by Angle" OBJ_TRENDBYANGLE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/           
      void CreateTrendByAngle    (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_TRENDBYANGLE,      aSubWindow,0,0);Attach(aName,aChartID);}

		/*!	
			Creation of the "Equidistant Channel" OBJ_CHANNEL object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/        
      void CreateChannel         (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_CHANNEL,           aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Standard Deviation Channel" OBJ_STDDEVCHANNEL object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/        
      void CreateStdDevChannel   (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_STDDEVCHANNEL,     aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Linear Regression Channel" OBJ_REGRESSION object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/        
      void CreateRegresion       (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_REGRESSION,        aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Andrews' Pitchfork" OBJ_PITCHFORK object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreatePitchFork       (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_PITCHFORK,         aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Gann Line" OBJ_GANNLINE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateGannLine        (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_GANNLINE,          aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Gann Fan" OBJ_GANNFAN object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateGannFan         (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_GANNFAN,           aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Gann Grid" OBJ_GANNGRID object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateGannGrid        (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_GANNGRID,          aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Fibonacci Retracement" OBJ_FIBO object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateFibo            (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_FIBO,              aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Fibonacci Time Zones" OBJ_FIBOTIMES object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateFiboTimes       (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_FIBOTIMES,         aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Fibonacci Fan" OBJ_FIBOFAN object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateFiboFan         (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_FIBOFAN,           aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Fibonacci Arcs" OBJ_FIBOARC object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateFiboArc         (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_FIBOARC,           aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Fibonacci Channel" OBJ_FIBOCHANNEL object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateFiboChannel     (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_FIBOCHANNEL,       aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Fibonacci Expansion" OBJ_EXPANSION object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateExpansion       (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_EXPANSION,         aSubWindow,0,0);Attach(aName,aChartID);}	
		
		/*!	
			Creation of the "Elliott 5-Wave Pattern" OBJ_ELLIOTWAVE5 object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateElliotWave5     (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ELLIOTWAVE5,       aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Elliott 3-Wave Pattern" OBJ_ELLIOTWAVE3 object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateElliotWave3     (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ELLIOTWAVE3,       aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Rectangle" OBJ_RECTANGLE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateRectangle       (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_RECTANGLE,         aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Triangle" OBJ_TRIANGLE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateTriangle        (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_TRIANGLE,          aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Ellipse" OBJ_ELLIPSE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateEllipse         (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ELLIPSE,           aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Cycle Lines" OBJ_CYCLES object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateCycles          (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_CYCLES,            aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Thumbs Up" OBJ_ARROW_THUMB_UP symbol.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateThumbUp         (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_THUMB_UP,    aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Thumbs Down" OBJ_ARROW_THUMB_DOWN symbol.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateTumbDn          (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_THUMB_DOWN,  aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Up Arrow" OBJ_ARROW_UP symbol.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrowUp         (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_UP,          aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Down Arrow" OBJ_ARROW_DOWN symbol.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrowDn         (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_DOWN,        aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Stop" OBJ_ARROW_STOP symbol.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrowStop       (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_STOP,        aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Tick" (Check) OBJ_ARROW_CHECK symbol.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrowCheck      (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_CHECK,       aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Left Price Label" OBJ_ARROW_LEFT_PRICE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrowLeftPrice  (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_LEFT_PRICE,  aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Right Price Label" OBJ_ARROW_RIGHT_PRICE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrowRightPrice (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_RIGHT_PRICE, aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Buy" OBJ_ARROW_BUY symbol.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrowBuy        (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_BUY,         aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Sell" OBJ_ARROW_SEL symbol.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrowSell       (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW_SELL,        aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Arrow" OBJ_ARROW object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrow           (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROW,             aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Text" OBJ_TEXT object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateText            (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_TEXT,              aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Text Label" OBJ_LABEL object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateLabel           (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_LABEL,             aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Button" OBJ_BUTTON object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateButton          (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_BUTTON,            aSubWindow,0,0);Attach(aName,aChartID);}	      
		
		/*!	
			Creation of the "Chart" OBJ_CHART object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateChart           (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_CHART,             aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Bitmap" OBJ_BITMAP object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateBitmap          (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_BITMAP,            aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Bitmap Label" OBJ_BITMAP_LABEL object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreatePitmapLabel     (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_BITMAP_LABEL,      aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Edit" OBJ_EDIT object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateEdit            (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_EDIT,              aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Arrowed Line" OBJ_ARROWED_LINE object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateArrowedLine     (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_ARROWED_LINE,      aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Event" OBJ_EVENT object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateEvent           (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_EVENT,             aSubWindow,0,0);Attach(aName,aChartID);}
		
		/*!	
			Creation of the "Rectangle Label" OBJ_RECTANGLE_LABEL object.
		 	\param		string aName - name of the graphical object under creation,
		 	\param		int aSubWindow=0 - subwindow where the graphical object is created,
		 	\param		long aChartID=0 - identifier of the chart where the graphical object is created.			
		*/  
      void CreateRectangleLabel  (string aName,int aSubWindow=0,long aChartID=0){ObjectCreate(aChartID,aName,OBJ_RECTANGLE_LABEL,   aSubWindow,0,0);Attach(aName,aChartID);}

      //+------------------------------------------------------------------+
      //|   Getting the attached object properties                  |
      //+------------------------------------------------------------------+         

		/*!	
			Color OBJPROP_COLOR.
		 	\return  Color value (color type).		
		*/  
      color                   Color       ()             {return( (color)                    ObjectGetInteger(m_id,m_name,OBJPROP_COLOR));}

		/*!	
			Style OBJPROP_STYLE.
		 	\return  Style value (ENUM_LINE_STYLE type).		
		*/        
      ENUM_LINE_STYLE         Style       ()             {return( (ENUM_LINE_STYLE)          ObjectGetInteger(m_id,m_name,OBJPROP_STYLE));}

		/*!	
			Width OBJPROP_WIDTH.
		 	\return  Width value (int type).		
		*/         
      int                     Width       ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_WIDTH));} 

		/*!	
			Background position of an object OBJPROP_BACK.
		 	\return  bool type. True - in the background, false - in the foreground.		
		*/        
      bool                    Back        ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_BACK));} 	

		/*!	
			Filling an object with a color OBJPROP_FILL (for OBJ_RECTANGLE, OBJ_TRIANGLE, OBJ_ELLIPSE, OBJ_CHANNEL, OBJ_STDDEVCHANNEL, OBJ_REGRESSION)
		 	\return  bool type. True - filled, false - outlined.	
		*/       
      bool                    Fill        ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_FILL));} 		

		/*!	
			Object selection OBJPROP_SELECTED.
		 	\return  bool type. True - selected, false - not selected.	
		*/       
      bool                    Selected    ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_SELECTED));} 		

		/*!	
			The "Edit" object text editing option OBJPROP_SELECTED.
		 	\return  bool type. True - editing not allowed, false - editing allowed.	
		*/  
      bool                    ReadOnly    ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_READONLY));} 		

		/*!	
			Object type OBJPROP_TYPE.
		 	\return  ENUM_OBJECT type.	
		*/       
      ENUM_OBJECT             Type        ()             {return( (ENUM_OBJECT)              ObjectGetInteger(m_id,m_name,OBJPROP_TYPE));}

		/*!	
			Object anchor point time OBJPROP_TIME.
         \param   int aIndex - anchor point number (from zero).
		 	\return  Time value (datetime type).		
		*/       
      datetime                Time        (int aIndex)   {return( (datetime)                 ObjectGetInteger(m_id,m_name,OBJPROP_TIME,aIndex));}	

		/*!	
			Object selection option OBJPROP_SELECTABLE.
		 	\return  bool type. True - selection allowed, false - not allowed.	
		*/         
      bool                    Selectable  ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_SELECTABLE));} 		

		/*!	
			Object creation time OBJPROP_CREATETIME.
		 	\return  Time value (datetime type).		
		*/       
      datetime                CreateTime  ()             {return( (datetime)                 ObjectGetInteger(m_id,m_name,OBJPROP_CREATETIME));}	

		/*!	
			Number of levels OBJPROP_LEVELS).
		 	\return  Value (int type).		
		*/    
      int                     Levels      ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_LEVELS));}	

		/*!	
			Level color OBJPROP_LEVELCOLOR.
         \param   int aIndex - level number (from zero).
		 	\return  Color value (color type).		
		*/  
      color                   LevelColor  (int aIndex)   {return( (color)                    ObjectGetInteger(m_id,m_name,OBJPROP_LEVELCOLOR,aIndex));}		

		/*!	
			Level style OBJPROP_LEVELSTYLE.
         \param   int aIndex - level number (from zero).
		 	\return  Style value (ENUM_LINE_STYLE type).		
		*/        
      ENUM_LINE_STYLE         LevelStyle  (int aIndex)   {return( (ENUM_LINE_STYLE)          ObjectGetInteger(m_id,m_name,OBJPROP_LEVELSTYLE,aIndex));}	

		/*!	
			Level width OBJPROP_LEVELWIDTH.
         \param   int aIndex - level number (from zero).
		 	\return  Width value (int type).		
		*/  
      int                     LevelWidth  (int aIndex)   {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_LEVELWIDTH,aIndex));}		

		/*!	
			Font size OBJPROP_FONTSIZE.
		 	\return  Size value (int type).		
		*/        
      int                     FontSize    ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_FONTSIZE));}		   

		/*!	
			Ray extension to the left OBJPROP_RAY_LEFT.
		 	\return  bool type. True - ray to the left is present, false - no ray.		
		*/       
      bool                    RayLeft     ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_RAY_LEFT));} 	

		/*!	
			Ray extension to the right OBJPROP_RAY_RIGHT.
		 	\return  bool type. True - ray to the right is present, false - no ray.		
		*/         
      bool                    RayRight    ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_RAY_RIGHT));} 		

		/*!	
			Vertical line runs through all chart windows OBJPROP_RAY.
		 	\return  bool type. True - runs through all chart windows, false - is confined to one subwindow.		
		*/   
      bool                    Ray         ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_RAY));} 		

		/*!	
			Display of a full ellipse in the "Fibonacci Arcs" object OBJPROP_ELLIPSE.
      	\return  bool type. True - full ellipse, false - arcs.		
		*/  
      bool                    Ellipse     ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_ELLIPSE));} 			   

		/*!	
			Arrow code for the "Arrow" object OBJPROP_ARROWCODE.
      	\return  Arrow code (char type).
		*/ 
      char                    ArrowCode   ()             {return( (char)                     ObjectGetInteger(m_id,m_name,OBJPROP_ARROWCODE));}

		/*!	
			Visibility of an object within the timeframes OBJPROP_TIMEFRAMES.
      	\return  Visibility flag set (long type).
		*/ 
      long                    TimeFrames  ()             {return(                            ObjectGetInteger(m_id,m_name,OBJPROP_TIMEFRAMES));}

		/*!	
			Anchor point position OBJPROP_ANCHOR.
      	\return  Anchor point value (long type). For OBJ_ARROW one of the ENUM_ARROW_ANCHOR values, for OBJ_LABEL and OBJ_TEXT - one of the ENUM_ANCHORPOINT values.
		*/       
      long                    Anchor      ()             {return(                            ObjectGetInteger(m_id,m_name,OBJPROP_ANCHOR));}

		/*!	
			Distance from the anchor corner along the X-axis in pixels OBJPROP_XDISTANCE.
      	\return  Value (int type).
		*/      
      int                     XDistance   ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_XDISTANCE));}	

		/*!	
			Distance from the anchor corner along the Y-axis in pixels OBJPROP_YDISTANCE.
      	\return  Value (int type).
		*/        
      int                     YDistance   ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_YDISTANCE));}	

		/*!	
			Gann object trend OBJPROP_DIRECTION.
      	\return  Value (ENUM_GANN_DIRECTION type).
		*/   
      ENUM_GANN_DIRECTION     Direction   ()             {return( (ENUM_GANN_DIRECTION)      ObjectGetInteger(m_id,m_name,OBJPROP_DIRECTION));}

		/*!	
			Elliott Wave degree OBJPROP_DEGREE.
      	\return  Value (ENUM_ELLIOT_WAVE_DEGREE type).
		*/        
      ENUM_ELLIOT_WAVE_DEGREE Degree      ()             {return( (ENUM_ELLIOT_WAVE_DEGREE)  ObjectGetInteger(m_id,m_name,OBJPROP_DEGREE));}

		/*!	
			Elliott Wave grid lines display OBJPROP_DRAWLINES.
      	\return  bool type. True - enabled, false - disabled.		
		*/  
      bool                    DrawLines   ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_DRAWLINES));} 

		/*!	
			Button state (On/Off) OBJPROP_STATE.
      	\return  bool type. True - on, false - off.
		*/ 
      bool                    State       ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_STATE));} 

		/*!	
			"Chart" object identifier OBJPROP_CHART_ID.
      	\return  Identifier value (long type).
		*/ 
      long                    ChartChartID()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_CHART_ID));}

		/*!	
			Horizontal size of an object OBJPROP_XSIZE.
      	\return  Size value (int type).
		*/       
      int                     XSize       ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_XSIZE));}	

		/*!	
			Vertical size of an object OBJPROP_YSIZE.
      	\return  Size value (int type).
		*/ 
      int                     YSize       ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_YSIZE));}		

		/*!	
			X-coordinate of the beginning of the object visibility area OBJPROP_XOFFSET.
      	\return  Value (int type).
		*/ 
      int                     XOffset     ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_XOFFSET));}	

		/*!	
			Y-coordinate of the beginning of the object visibility area OBJPROP_YOFFSET.
      	\return  Value (int type).
		*/ 
      int                     YOffset     ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_YOFFSET));}	

		/*!	
			"Chart" object timeframe OBJPROP_PERIOD.
      	\return  Value (ENUM_TIMEFRAMES type).
		*/       
      ENUM_TIMEFRAMES         Period      ()             {return( (ENUM_TIMEFRAMES)          ObjectGetInteger(m_id,m_name,OBJPROP_PERIOD));}

		/*!	
			"Chart" object date scale display OBJPROP_DATE_SCALE.
      	\return  bool type. True - scale is present, false - no scale.
		*/ 
      bool                    DateScale   ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_DATE_SCALE));} 

		/*!	
			"Chart" object price scale display OBJPROP_PRICE_SCALE.
      	\return  bool type. True - scale is present, false - no scale.
		*/       
      bool                    PriceScale  ()             {return( (bool)                     ObjectGetInteger(m_id,m_name,OBJPROP_PRICE_SCALE));} 

		/*!	
			"Chart" object scale OBJPROP_CHART_SCALE.
      	\return  Value 1-5 (int type).
		*/        
      int                     ChartScale  ()             {return( (int)                      ObjectGetInteger(m_id,m_name,OBJPROP_CHART_SCALE));}		

		/*!	
			Background color OBJPROP_BGCOLOR.
		 	\return  Color value (color type).		
		*/  
      color                   BgColor     ()             {return( (color)                    ObjectGetInteger(m_id,m_name,OBJPROP_BGCOLOR));}

		/*!	
			Chart corner for binding a graphical object OBJPROP_CORNER.
		 	\return  Value (ENUM_BASE_CORNER type).
		*/  
      ENUM_BASE_CORNER        Corner      ()             {return( (ENUM_BASE_CORNER)         ObjectGetInteger(m_id,m_name,OBJPROP_CORNER));}

		/*!	
			"Rectangle Frame" object border type OBJPROP_BORDER_TYPE.
		 	\return  Value (ENUM_BORDER_TYPE type).
		*/        
      ENUM_BORDER_TYPE        BorderType  ()             {return( (ENUM_BORDER_TYPE)         ObjectGetInteger(m_id,m_name,OBJPROP_BORDER_TYPE));}

		/*!	
			Price coordinate OBJPROP_PRICE.
         \param   int aIndex - point number (from zero).
		 	\return  Value (double type).
		*/    
      double                  Price       (int aIndex)   {return(                            ObjectGetDouble(m_id,m_name,OBJPROP_PRICE,aIndex));} 

		/*!	
			Level value OBJPROP_LEVELVALUE.
         \param   int aIndex - level number (from zero).
		 	\return  Value (double type).
		*/          
      double                  LevelValue  (int aIndex)   {return(                            ObjectGetDouble(m_id,m_name,OBJPROP_LEVELVALUE,aIndex));}  

		/*!	
			Scale (property of Gann objects and "Fibonacci Arcs" object) OBJPROP_SCALE.
		 	\return  Value (double type).
		*/        
      double                  Scale       ()             {return(                            ObjectGetDouble(m_id,m_name,OBJPROP_SCALE));}

		/*!	
			Angle OBJPROP_ANGLE.
		 	\return  Value (double type).
		*/ 
      double                  Angle       ()             {return(                            ObjectGetDouble(m_id,m_name,OBJPROP_ANGLE));}

		/*!	
			Deviation for standard deviation channel OBJPROP_DEVIATION.
		 	\return  Value (double type).
		*/       
      double                  Deviation   ()             {return(                            ObjectGetDouble(m_id,m_name,OBJPROP_DEVIATION));}

		/*!	
			Object text OBJPROP_TEXT.
		 	\return  Text.
		*/  
      string                  Text        ()             {return(                            ObjectGetString(m_id,m_name,OBJPROP_TEXT));}

		/*!	
			Tooltip text. OBJPROP_TOOLTIP.
		 	\return  Text.
		*/  
      string                  ToolTip     ()             {return(                            ObjectGetString(m_id,m_name,OBJPROP_TOOLTIP));}

		/*!	
			Level text. OBJPROP_LEVELTEXT.
         \param   int aIndex - level number (from zero).			
		 	\return  Text.
		*/        
      string                  LevelText   (int aIndex)   {return(                            ObjectGetString(m_id,m_name,OBJPROP_LEVELTEXT,aIndex));} 

		/*!	
			Font name. OBJPROP_FONT.
		 	\return  Name (string type).
		*/       
      string                  Font        ()             {return(                            ObjectGetString(m_id,m_name,OBJPROP_FONT));}

		/*!	
			BMP file for "On" state OBJPROP_BMPFILE, modifier 0.
		 	\return  File name (string type).
		*/       
      string                  BmpFileOn   ()             {return(                            ObjectGetString(m_id,m_name,OBJPROP_BMPFILE,0));}

		/*!	
			BMP file for "Off" state OBJPROP_BMPFILE, modifier 1.
		 	\return  File name (string type).
		*/    
      string                  BmpFileOff  ()             {return(                            ObjectGetString(m_id,m_name,OBJPROP_BMPFILE,1));}       

		/*!	
			"Chart" object symbol OBJPROP_SYMBOL.
		 	\return  Symbol (string type).
		*/  
      string                  Symbol      ()             {return(                            ObjectGetString(m_id,m_name,OBJPROP_SYMBOL));}  
      
      //+------------------------------------------------------------------+
      //|   Setting the attached object properties                       |
      //+------------------------------------------------------------------+    

		/*!	
			Color setting OBJPROP_COLOR.
         \param		color aValue - color value.			
		*/  
      void SetColor        (color aValue)                      {ObjectSetInteger(m_id,m_name,OBJPROP_COLOR,             aValue);}

		/*!	
			Style setting OBJPROP_STYLE.
         \param		ENUM_LINE_STYLE aValue - style value.			
		*/
      void SetStyle        (ENUM_LINE_STYLE aValue)            {ObjectSetInteger(m_id,m_name,OBJPROP_STYLE,             aValue);}

		/*!	
			Width setting OBJPROP_WIDTH.
         \param		int aValue - width value.			
		*/  
      void SetWidth        (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_WIDTH,             aValue);} 

		/*!	
			Background/foreground position setting OBJPROP_BACK.
         \param		bool aValue - true/false (background/foreground).
		*/        
      void SetBack         (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_BACK,              aValue);} 	

		/*!	
			Enabling the color fill OBJPROP_FILL.
         \param		bool aValue - true/false (filled/outlined).
		*/       
      void SetFill         (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_FILL,              aValue);} 		

		/*!	
			Enabling the selection OBJPROP_SELECTED.
         \param		bool aValue - true/false (selected/not selected).
		*/         
      void SetSelected     (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_SELECTED,          aValue);} 		

		/*!	
			Enabling the text editing option in the "Edit" object OBJPROP_READONLY.
         \param		bool aValue - true/false (allowed/not allowed).
		*/         
      void SetReadOnly     (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_READONLY,          aValue);} 		

		/*!	
			Setting the time of one of the anchor points OBJPROP_TIME.
         \param		int aIndex - point number (from zero),
         \param		datetime aValue - time value.
		*/    
      void SetTime         (int aIndex,datetime aValue)        {ObjectSetInteger(m_id,m_name,OBJPROP_TIME,              aIndex,aValue);}	

		/*!	
			Enabling the object selection option OBJPROP_SELECTABLE.
         \param		bool aValue - true/false (allowed/not allowed).
		*/       
      void SetSelectable   (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_SELECTABLE,        aValue);} 		

		/*!	
			Setting the number of levels OBJPROP_LEVELS.
         \param		int aValue - number of levels.
		*/       
      void SetLevels       (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_LEVELS,            aValue);}	

		/*!	
			Setting the level color OBJPROP_LEVELCOLOR.
         \param   int aIndex - level number (from zero),
         \param   color aValue - color value.
		*/        
      void SetLevelColor   (int aIndex,color aValue)           {ObjectSetInteger(m_id,m_name,OBJPROP_LEVELCOLOR,        aIndex,aValue);}		

		/*!	
			Setting the level style OBJPROP_LEVELSTYLE.
         \param   int aIndex - level number (from zero),
         \param   ENUM_LINE_STYLE aValue - style value.
		*/  
      void SetLevelStyle   (int aIndex,ENUM_LINE_STYLE aValue) {ObjectSetInteger(m_id,m_name,OBJPROP_LEVELSTYLE,        aIndex,aValue);}

		/*!	
			Setting the level width OBJPROP_LEVELWIDTH.
         \param   int aIndex - level number (from zero),
         \param   int aValue - width value.
		*/  
      void SetLevelWidth   (int aIndex,int aValue)             {ObjectSetInteger(m_id,m_name,OBJPROP_LEVELWIDTH,        aIndex,aValue);}		

		/*!	
			Setting the font size OBJPROP_FONTSIZE.
         \param   int aValue - size value.
		*/  
      void SetFontSize     (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_FONTSIZE,          aValue);}		   

		/*!	
			Enabling the ray to the left OBJPROP_RAY_LEFT.
         \param   bool aValue - true/false (enabled/disabled).
		*/  
      void SetRayLeft      (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_RAY_LEFT,          aValue);} 	

		/*!	
			Enabling the ray to the right OBJPROP_RAY_RIGHT.
         \param   bool aValue - true/false (enabled/disabled).
		*/        
      void SetRayRight     (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_RAY_RIGHT,         aValue);} 		

		/*!	
			Enabling the extension of the vertical line in subwindows OBJPROP_RAY.
         \param   bool aValue - true/false (enabled/disabled).
		*/   
      void SetRay          (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_RAY,               aValue);} 		

		/*!	
			Enabling the display of a full ellipse in the "Fibonacci Arcs" object OBJPROP_ELLIPSE.
         \param   bool aValue - true/false (ellipse/arcs).
		*/        
      void SetEllipse      (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_ELLIPSE,           aValue);} 			   

		/*!	
			Setting the arrow code OBJPROP_ARROWCODE.
         \param   char aValue - arrow code.
		*/        
      void SetArrowCode    (char aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_ARROWCODE,         aValue);}

		/*!	
			Setting the visibility of an object within the timeframes OBJPROP_TIMEFRAMES.
         \param   long aValue - flag combination.
		*/           
      void SetTimeFrames   (long aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_TIMEFRAMES,        aValue);}

		/*!	
			Setting the anchor point OBJPROP_ANCHOR.
         \param   long aValue - anchor point (ENUM_ARROW_ANCHOR or ENUM_ANCHORPOINT).
		*/    
      void SetAnchor       (long aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_ANCHOR,            aValue);}

		/*!	
			Setting the distance from the anchor corner along the X-axis OBJPROP_XDISTANCE.
         \param   int aValue - distance value.
		*/    
      void SetXDistance    (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_XDISTANCE,         aValue);}	

		/*!	
			Setting the distance from the anchor corner along the Y-axis OBJPROP_YDISTANCE.
         \param   int aValue - distance value.
		*/          
      void SetYDistance    (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_YDISTANCE,         aValue);}	

		/*!	
			Setting the Gann object trend OBJPROP_DIRECTION.
         \param   ENUM_GANN_DIRECTION aValue - trend value.
		*/ 
      void SetDirection    (ENUM_GANN_DIRECTION aValue)        {ObjectSetInteger(m_id,m_name,OBJPROP_DIRECTION,         aValue);}

		/*!	
			Setting the Elliott Wave degree OBJPROP_DEGREE.
         \param   ENUM_ELLIOT_WAVE_DEGREE aValue - degree value.
		*/ 
      void SetDegree       (ENUM_ELLIOT_WAVE_DEGREE aValue)    {ObjectSetInteger(m_id,m_name,OBJPROP_DEGREE,            aValue);}

		/*!	
			Enabling the Elliott Wave grid lines OBJPROP_DRAWLINES.
         \param   bool aValue - true/false (enabled/disabled).
		*/       
      void SetDrawLines    (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_DRAWLINES,         aValue);} 

		/*!	
			Setting the button state.
         \param   bool aValue - true/false (on/off).
		*/        
      void SetState        (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_STATE,             aValue);} 

		/*!	
			Setting the horizontal size OBJPROP_XSIZE.
         \param   int aValue - size value.
		*/       
      void SetXSize        (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_XSIZE,             aValue);}	

		/*!	
			Setting the vertical size OBJPROP_YSIZE.
         \param   int aValue - size value.
		*/          
      void SetYSize        (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_YSIZE,             aValue);}		

		/*!	
			Setting the X-coordinate of the beginning of the visibility area OBJPROP_XOFFSET.
         \param   int aValue - coordinate value.
		*/ 
      void SetXOffset      (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_XOFFSET,           aValue);}	

		/*!	
			Setting the Y-coordinate of the beginning of the visibility area OBJPROP_YOFFSET.
         \param   int aValue - coordinate value.
		*/ 
      void SetYOffset      (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_YOFFSET,           aValue);}	

		/*!	
			Setting the "Chart" object timeframe OBJPROP_PERIOD.
         \param   ENUM_TIMEFRAMES aValue - timeframe value.
		*/ 
      void SetPeriod       (ENUM_TIMEFRAMES aValue)            {ObjectSetInteger(m_id,m_name,OBJPROP_PERIOD,            aValue);}

		/*!	
			Enabling/disabling the "Chart" object date scale visibility OBJPROP_DATE_SCALE.
         \param   bool aValue - true/false (enabled/disabled).
		*/ 
      void SetDateScale    (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_DATE_SCALE,        aValue);} 

		/*!	
			Enabling/disabling the "Chart" object price scale visibility OBJPROP_PRICE_SCALE.
         \param   bool aValue - true/false (enabled/disabled).
		*/       
      void SetPriceScale   (bool aValue)                       {ObjectSetInteger(m_id,m_name,OBJPROP_PRICE_SCALE,       aValue);} 

		/*!	
			Setting the "Chart" object scale OBJPROP_CHART_SCALE.
         \param   int aValue - value 1-5.
		*/         
      void SetChartScale   (int aValue)                        {ObjectSetInteger(m_id,m_name,OBJPROP_CHART_SCALE,       aValue);}		

		/*!	
			Setting the background color OBJPROP_BGCOLOR.
         \param   color aValue - color value.
		*/        
      void SetBgColor      (color aValue)                      {ObjectSetInteger(m_id,m_name,OBJPROP_BGCOLOR,           aValue);}

		/*!	
			Setting the chart corner for binding OBJPROP_CORNER.
         \param   ENUM_BASE_CORNER aValue - chart corner.
		*/       
      void SetCorner       (ENUM_BASE_CORNER aValue)           {ObjectSetInteger(m_id,m_name,OBJPROP_CORNER,            aValue);}

		/*!	
			Setting the "Rectangle Frame" object border type OBJPROP_BORDER_TYPE.
         \param   ENUM_BORDER_TYPE aValue - border type.
		*/        
      void SetBorderType   (ENUM_BORDER_TYPE aValue)           {ObjectSetInteger(m_id,m_name,OBJPROP_BORDER_TYPE,       aValue);}      

		/*!	
			Setting the price value OBJPROP_PRICE.
         \param   int aIndex - point number (from zero),
		 	\param  double aValue - value.
		*/   
      void SetPrice        (int aIndex,double aValue)          {ObjectSetDouble(m_id,m_name,OBJPROP_PRICE,              aIndex,aValue);} 

		/*!	
			Setting the level value OBJPROP_LEVELVALUE.
         \param   int aIndex - level number (from zero),
		 	\param  double aValue - value.
		*/        
      void SetLevelValue   (int aIndex,double aValue)          {ObjectSetDouble(m_id,m_name,OBJPROP_LEVELVALUE,         aIndex,aValue);}  

		/*!	
			Setting the scale (property of Gann objects and "Fibonacci Arcs" object) OBJPROP_SCALE.
		 	\param  double aValue - scale value.
		*/       
      void SetScale        (double aValue)                     {ObjectSetDouble(m_id,m_name,OBJPROP_SCALE,              aValue);}     

		/*!	
			Setting the angle OBJPROP_ANGLE.
		 	\param  double aValue - angle value OBJPROP_ANGLE.
		*/       
      void SetAngle        (double aValue)                     {ObjectSetDouble(m_id,m_name,OBJPROP_ANGLE,              aValue);}

		/*!	
			Setting the standard deviation channel width OBJPROP_DEVIATION.
		 	\param  double aValue - width value (number of standard deviations).
		*/         
      void SetDeviation    (double aValue)                     {ObjectSetDouble(m_id,m_name,OBJPROP_DEVIATION,          aValue);}

		/*!	
			Setting the text OBJPROP_TEXT.
		 	\param  string aValue - text.
		*/   
      void SetText         (string aValue)                     {ObjectSetString(m_id,m_name,OBJPROP_TEXT,               aValue);}

		/*!	
			Setting the tooltip OBJPROP_TOOLTIP.
		 	\param  string aValue - text.
		 	\remark Set value "\n" to disable the tooltip.		 	
		*/       
      void SetToolTip      (string aValue)                     {ObjectSetString(m_id,m_name,OBJPROP_TOOLTIP,            aValue);}

		/*!	
			Setting the level text OBJPROP_LEVELTEXT.
         \param   int aIndex - level number (from zero),
		 	\param  string aValue - text. 	
		*/       
      void SetLevelText    (int aIndex,string aValue)          {ObjectSetString(m_id,m_name,OBJPROP_LEVELTEXT,          aIndex,aValue);} 

		/*!	
			Setting the font type OBJPROP_FONT.
		 	\param  string aValue - font name. 	
		*/        
      void SetFont         (string aValue)                     {ObjectSetString(m_id,m_name,OBJPROP_FONT,               aValue);} 

		/*!	
			Setting the BMP file for "On" state OBJPROP_BMPFILE, modifier 0.
		 	\param  string aValue - file name. 	
		*/         
      void SetBmpFileOn    (string aValue)                     {ObjectSetString(m_id,m_name,OBJPROP_BMPFILE,            0,aValue);}       

		/*!	
			Setting the BMP file for "Off" state OBJPROP_BMPFILE, modifier 1.
		 	\param  string aValue - file name. 	
		*/        
      void SetBmpFileOff   (string aValue)                     {ObjectSetString(m_id,m_name,OBJPROP_BMPFILE,            1,aValue);}       

		/*!	
			Setting the "Chart" object symbol OBJPROP_SYMBOL.
		 	\param  string aValue - symbol. 	
		*/      
      void SetSymbol       (string aValue)                     {ObjectSetString(m_id,m_name,OBJPROP_SYMBOL,             aValue);}  
      
      //+------------------------------------------------------------------+
      //|   Getting the properties by the object name                             |
      //+------------------------------------------------------------------+         
   
		/*!	
			Color OBJPROP_COLOR.
			\param  string aName - graphical object name. 
		 	\return  Color value (color type).		
		*/     
      color                   Color       (string aName)             {return( (color)                    ObjectGetInteger(0,aName,OBJPROP_COLOR));}
		
		/*!	
			Style OBJPROP_STYLE.
         \param  string aName - graphical object name. 			
		 	\return  Style value (ENUM_LINE_STYLE type).		
		*/        
      ENUM_LINE_STYLE         Style       (string aName)             {return( (ENUM_LINE_STYLE)          ObjectGetInteger(0,aName,OBJPROP_STYLE));}
		
		/*!	
			Width OBJPROP_WIDTH.
         \param  string aName - graphical object name. 						
		 	\return  Width value (int type).		
		*/  
      int                     Width       (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_WIDTH));} 
		
		/*!	
			Background position of an object OBJPROP_BACK.
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - in the background, false - in the foreground.		
		*/    
      bool                    Back        (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_BACK));} 	
		
		/*!	
			Filling an object with a color OBJPROP_FILL (for OBJ_RECTANGLE, OBJ_TRIANGLE, OBJ_ELLIPSE, OBJ_CHANNEL, OBJ_STDDEVCHANNEL, OBJ_REGRESSION)
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - filled, false - outlined.	
		*/  
      bool                    Fill        (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_FILL));} 		
		
		/*!	
			Object selection OBJPROP_SELECTED.
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - selected, false - not selected.	
		*/  
      bool                    Selected    (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_SELECTED));} 		
		
		/*!	
			The "Edit" object text editing option OBJPROP_SELECTED.
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - editing not allowed, false - editing allowed.	
		*/  
      bool                    ReadOnly    (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_READONLY));} 		
		
		/*!	
			Object type OBJPROP_TYPE.
         \param  string aName - graphical object name. 			
		 	\return  ENUM_OBJECT type.	
		*/  
      ENUM_OBJECT             Type        (string aName)             {return( (ENUM_OBJECT)              ObjectGetInteger(0,aName,OBJPROP_TYPE));}
		
		/*!	
			Object anchor point time OBJPROP_TIME.
         \param  string aName - graphical object name,
         \param   int aIndex - anchor point number (from zero).
		 	\return  Time value (datetime type).		
		*/  
      datetime                Time        (string aName,int aIndex)  {return( (datetime)                 ObjectGetInteger(0,aName,OBJPROP_TIME,aIndex));}	
		
		/*!	
			Object selection option OBJPROP_SELECTABLE.
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - selection allowed, false - not allowed.	
		*/   
      bool                    Selectable  (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_SELECTABLE));} 		
		
		/*!	
			Object creation time OBJPROP_CREATETIME.
         \param  string aName - graphical object name. 						
		 	\return  Time value (datetime type).		
		*/  
      datetime                CreateTime  (string aName)             {return( (datetime)                 ObjectGetInteger(0,aName,OBJPROP_CREATETIME));}	
		
		/*!	
			Number of levels OBJPROP_LEVELS).
         \param  string aName - graphical object name. 						
		 	\return  Value (int type).		
		*/   
      int                     Levels      (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_LEVELS));}	
		
		/*!	
			Level color OBJPROP_LEVELCOLOR.
         \param   int aIndex - level number (from zero).
         \param  string aName - graphical object name. 			         
		 	\return  Color value (color type).		
		*/ 
      color                   LevelColor  (string aName,int aIndex)  {return( (color)                    ObjectGetInteger(0,aName,OBJPROP_LEVELCOLOR,aIndex));}		
		
		/*!	
			Level style OBJPROP_LEVELSTYLE.
         \param   int aIndex - level number (from zero).
         \param  string aName - graphical object name. 			         
		 	\return  Style value (ENUM_LINE_STYLE type).		
		*/  
      ENUM_LINE_STYLE         LevelStyle  (string aName,int aIndex)  {return( (ENUM_LINE_STYLE)          ObjectGetInteger(0,aName,OBJPROP_LEVELSTYLE,aIndex));}	
		
		/*!	
			Level width OBJPROP_LEVELWIDTH.
         \param   int aIndex - level number (from zero).
         \param  string aName - graphical object name. 			         
		 	\return  Width value (int type).		
		*/  
      int                     LevelWidth  (string aName,int aIndex)  {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_LEVELWIDTH,aIndex));}		
		
		/*!	
			Font size OBJPROP_FONTSIZE.
         \param  string aName - graphical object name. 						
		 	\return  Size value (int type).		
		*/  
      int                     FontSize    (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_FONTSIZE));}		   
		
		/*!	
			Ray extension to the left OBJPROP_RAY_LEFT.
         \param  string aName - graphical object name. 						
		 	\return  bool type. True - ray to the left is present, false - no ray.		
		*/    
      bool                    RayLeft     (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_RAY_LEFT));} 	
		
		/*!	
			Ray extension to the right OBJPROP_RAY_RIGHT.
         \param  string aName - graphical object name. 						
		 	\return  bool type. True - ray to the right is present, false - no ray.		
		*/  
      bool                    RayRight    (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_RAY_RIGHT));} 		
		
		/*!	
			Vertical line runs through all chart windows OBJPROP_RAY.
         \param  string aName - graphical object name. 						
		 	\return  bool type. True - runs through all chart windows, false - is confined to one subwindow.		
		*/  
      bool                    Ray         (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_RAY));} 		
		
		/*!	
			Display of a full ellipse in the "Fibonacci Arcs" object OBJPROP_ELLIPSE.
         \param  string aName - graphical object name. 						
      	\return  bool type. True - full ellipse, false - arcs.		
		*/ 
      bool                    Ellipse     (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_ELLIPSE));} 			   
		
		/*!	
			Arrow code for the "Arrow" object OBJPROP_ARROWCODE.
         \param  string aName - graphical object name. 						
      	\return  Arrow code (char type).
		*/ 
      char                    ArrowCode   (string aName)             {return( (char)                     ObjectGetInteger(0,aName,OBJPROP_ARROWCODE));}
		
		/*!	
			Visibility of an object within the timeframes OBJPROP_TIMEFRAMES.
         \param  string aName - graphical object name. 						
      	\return  Visibility flag set (long type).
		*/ 
      long                    TimeFrames  (string aName)             {return(                            ObjectGetInteger(0,aName,OBJPROP_TIMEFRAMES));}
		
		/*!	
			Anchor point position OBJPROP_ANCHOR.
         \param  string aName - graphical object name. 						
      	\return  Anchor point value (long type). For OBJ_ARROW one of the ENUM_ARROW_ANCHOR values, for OBJ_LABEL and OBJ_TEXT - one of the ENUM_ANCHORPOINT values.
		*/   
      long                    Anchor      (string aName)             {return(                            ObjectGetInteger(0,aName,OBJPROP_ANCHOR));}
		
		/*!	
			Distance from the anchor corner along the X-axis in pixels OBJPROP_XDISTANCE.
         \param  string aName - graphical object name. 						
      	\return  Value (int type).
		*/ 
      int                     XDistance   (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_XDISTANCE));}	
		
		/*!	
			Distance from the anchor corner along the Y-axis in pixels OBJPROP_YDISTANCE.
         \param  string aName - graphical object name. 						
      	\return  Value (int type).
		*/  
      int                     YDistance   (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_YDISTANCE));}	
		
		/*!	
			Gann object trend OBJPROP_DIRECTION.
         \param  string aName - graphical object name. 						
      	\return  Value (ENUM_GANN_DIRECTION type).
		*/   
      ENUM_GANN_DIRECTION     Direction   (string aName)             {return( (ENUM_GANN_DIRECTION)      ObjectGetInteger(0,aName,OBJPROP_DIRECTION));}
		
		/*!	
			Elliott Wave degree OBJPROP_DEGREE.
         \param  string aName - graphical object name. 						
      	\return  Value (ENUM_ELLIOT_WAVE_DEGREE type).
		*/   
      ENUM_ELLIOT_WAVE_DEGREE Degree      (string aName)             {return( (ENUM_ELLIOT_WAVE_DEGREE)  ObjectGetInteger(0,aName,OBJPROP_DEGREE));}
		
		/*!	
			Elliott Wave grid lines display OBJPROP_DRAWLINES.
         \param  string aName - graphical object name. 						
      	\return  bool type. True - enabled, false - disabled.		
		*/  
      bool                    DrawLines   (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_DRAWLINES));} 
		
		/*!	
			Button state (On/Off) OBJPROP_STATE.
         \param  string aName - graphical object name. 						
      	\return  bool type. True - on, false - off.
		*/ 
      bool                    State       (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_STATE));} 
		
		/*!	
			"Chart" object identifier OBJPROP_CHART_ID.
         \param  string aName - graphical object name. 						
      	\return  Identifier value (long type).
		*/ 
      long                    ChartChartID(string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_CHART_ID));}
		
		/*!	
			Horizontal size of an object OBJPROP_XSIZE.
         \param  string aName - graphical object name. 						
      	\return  Size value (int type).
		*/   
      int                     XSize       (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_XSIZE));}	
		
		/*!	
			Vertical size of an object OBJPROP_YSIZE.
         \param  string aName - graphical object name. 						
      	\return  Size value (int type).
		*/ 
      int                     YSize       (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_YSIZE));}		
		
		/*!	
			X-coordinate of the beginning of the object visibility area OBJPROP_XOFFSET.
         \param  string aName - graphical object name. 						
      	\return  Value (int type).
		*/ 
      int                     XOffset     (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_XOFFSET));}	
		
		/*!	
			Y-coordinate of the beginning of the object visibility area OBJPROP_YOFFSET.
         \param  string aName - graphical object name. 						
      	\return  Value (int type).
		*/ 
      int                     YOffset     (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_YOFFSET));}	
		
		/*!	
			"Chart" object timeframe OBJPROP_PERIOD.
         \param  string aName - graphical object name. 						
      	\return  Value (ENUM_TIMEFRAMES type).
		*/  
      ENUM_TIMEFRAMES         Period      (string aName)             {return( (ENUM_TIMEFRAMES)          ObjectGetInteger(0,aName,OBJPROP_PERIOD));}
		
		/*!	
			"Chart" object date scale display OBJPROP_DATE_SCALE.
         \param  string aName - graphical object name. 						
      	\return  bool type. True - scale is present, false - no scale.
		*/ 
      bool                    DateScale   (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_DATE_SCALE));} 
		
		/*!	
			"Chart" object price scale display OBJPROP_PRICE_SCALE.
         \param  string aName - graphical object name. 						
      	\return  bool type. True - scale is present, false - no scale.
		*/  
      bool                    PriceScale  (string aName)             {return( (bool)                     ObjectGetInteger(0,aName,OBJPROP_PRICE_SCALE));} 
		
		/*!	
			"Chart" object scale OBJPROP_CHART_SCALE.
         \param  string aName - graphical object name. 						
      	\return  Value 1-5 (int type).
		*/  
      int                     ChartScale  (string aName)             {return( (int)                      ObjectGetInteger(0,aName,OBJPROP_CHART_SCALE));}		
		
		/*!	
			Background color OBJPROP_BGCOLOR.
         \param  string aName - graphical object name. 						
		 	\return  Color value (color type).		
		*/  
      color                   BgColor     (string aName)             {return( (color)                    ObjectGetInteger(0,aName,OBJPROP_BGCOLOR));}
		
		/*!	
			Chart corner for binding a graphical object OBJPROP_CORNER.
         \param  string aName - graphical object name. 						
		 	\return  Value (ENUM_BASE_CORNER type).
		*/  
      ENUM_BASE_CORNER        Corner      (string aName)             {return( (ENUM_BASE_CORNER)         ObjectGetInteger(0,aName,OBJPROP_CORNER));}
		
		/*!	
			"Rectangle Frame" object border type OBJPROP_BORDER_TYPE.
         \param  string aName - graphical object name. 						
		 	\return  Value (ENUM_BORDER_TYPE type).
		*/   
      ENUM_BORDER_TYPE        BorderType  (string aName)             {return( (ENUM_BORDER_TYPE)         ObjectGetInteger(0,aName,OBJPROP_BORDER_TYPE));}
		
		/*!	
			Price coordinate OBJPROP_PRICE.
         \param  string aName - graphical object name,			
         \param   int aIndex - point number (from zero).
		 	\return  Value (double type).
		*/   
      double                  Price       (string aName,int aIndex)  {return(                            ObjectGetDouble(0,aName,OBJPROP_PRICE,aIndex));} 
		
		/*!	
			Level value OBJPROP_LEVELVALUE.
         \param  string aName - graphical object name,			
         \param   int aIndex - level number (from zero).
		 	\return  Value (double type).
		*/     
      double                  LevelValue  (string aName,int aIndex)  {return(                            ObjectGetDouble(0,aName,OBJPROP_LEVELVALUE,aIndex));}  
		
		/*!	
			Scale (property of Gann objects and "Fibonacci Arcs" object) OBJPROP_SCALE.
         \param  string aName - graphical object name. 						
		 	\return  Value (double type).
		*/   
      double                  Scale       (string aName)             {return(                            ObjectGetDouble(0,aName,OBJPROP_SCALE));}
		
		/*!	
			Angle OBJPROP_ANGLE.
         \param  string aName - graphical object name. 						
		 	\return  Value (double type).
		*/ 
      double                  Angle       (string aName)             {return(                            ObjectGetDouble(0,aName,OBJPROP_ANGLE));}
		
		/*!	
			Deviation for standard deviation channel OBJPROP_DEVIATION.
         \param  string aName - graphical object name. 						
		 	\return  Value (double type).
		*/  
      double                  Deviation   (string aName)             {return(                            ObjectGetDouble(0,aName,OBJPROP_DEVIATION));}
		
		/*!	
			Object text OBJPROP_TEXT.
         \param  string aName - graphical object name. 						
		 	\return  Text.
		*/  
      string                  Text        (string aName)             {return(                            ObjectGetString(0,aName,OBJPROP_TEXT));}
		
		/*!	
			Tooltip text. OBJPROP_TOOLTIP.
         \param  string aName - graphical object name. 						
		 	\return  Text.
		 	\remark Set value "\n" to disable the tooltip.
		*/  
      string                  ToolTip     (string aName)             {return(                            ObjectGetString(0,aName,OBJPROP_TOOLTIP));}
		
		/*!	
			Level text. OBJPROP_LEVELTEXT.
         \param  string aName - graphical object name,		
         \param   int aIndex - level number (from zero).			
		 	\return  Text.
		*/   
      string                  LevelText   (string aName,int aIndex)  {return(                            ObjectGetString(0,aName,OBJPROP_LEVELTEXT,aIndex));} 
		
		/*!	
			Font name. OBJPROP_FONT.
         \param  string aName - graphical object name. 						
		 	\return  Name (string type).
		*/   
      string                  Font        (string aName)             {return(                            ObjectGetString(0,aName,OBJPROP_FONT));}
		
		/*!	
			BMP file for "On" state OBJPROP_BMPFILE, modifier 0.
         \param  string aName - graphical object name. 						
		 	\return  File name (string type).
		*/   
      string                  BmpFileOn   (string aName)             {return(                            ObjectGetString(0,aName,OBJPROP_BMPFILE,0));}
		
		/*!	
			BMP file for "Off" state OBJPROP_BMPFILE, modifier 1.
         \param  string aName - graphical object name. 						
		 	\return  File name (string type).
		*/    
      string                  BmpFileOff  (string aName)             {return(                            ObjectGetString(0,aName,OBJPROP_BMPFILE,1));}       
		
		/*!	
			"Chart" object symbol OBJPROP_SYMBOL.
         \param  string aName - graphical object name. 						
		 	\return  Symbol (string type).
		*/  
      string                  Symbol      (string aName)             {return(                            ObjectGetString(0,aName,OBJPROP_SYMBOL));}  

      //+------------------------------------------------------------------+
      //|   Setting the properties by the object name.                            |
      //+------------------------------------------------------------------+          
      
		/*!	
			Color setting OBJPROP_COLOR.
			\param  string aName - graphical object name,
         \param		color aValue - color value.			
		*/  
      void SetColor        (string aName,color aValue)                        {ObjectSetInteger(0,aName,OBJPROP_COLOR,           aValue);}

		/*!	
			Style setting OBJPROP_STYLE.
			\param  string aName - graphical object name,
         \param		ENUM_LINE_STYLE aValue - style value.			
		*/
      void SetStyle        (string aName,ENUM_LINE_STYLE aValue)              {ObjectSetInteger(0,aName,OBJPROP_STYLE,           aValue);}

		/*!	
			Width setting OBJPROP_WIDTH.
			\param  string aName - graphical object name,
         \param		int aValue - width value.			
		*/ 
      void SetWidth        (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_WIDTH,           aValue);} 

		/*!	
			Background/foreground position setting OBJPROP_BACK.
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (background/foreground).
		*/   
      void SetBack         (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_BACK,            aValue);} 	

		/*!	
			Enabling the color fill OBJPROP_FILL.
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (filled/outlined).
		*/ 
      void SetFill         (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_FILL,            aValue);} 		

		/*!	
			Enabling the selection OBJPROP_SELECTED.
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (selected/not selected).
		*/ 
      void SetSelected     (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_SELECTED,        aValue);} 		

		/*!	
			Enabling the text editing option in the "Edit" object OBJPROP_READONLY.
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (allowed/not allowed).
		*/  
      void SetReadOnly     (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_READONLY,        aValue);} 		

		/*!	
			Setting the time of one of the anchor points OBJPROP_TIME.
         \param		int aIndex - point number (from zero),
         \param  string aName - graphical object name,
         \param		datetime aValue - time value.
		*/    
      void SetTime         (string aName,int aIndex,datetime aValue)          {ObjectSetInteger(0,aName,OBJPROP_TIME,            aIndex,aValue);}	

		/*!	
			Enabling the object selection option OBJPROP_SELECTABLE.
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (allowed/not allowed).
		*/ 
      void SetSelectable   (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_SELECTABLE,      aValue);} 		

		/*!	
			Setting the number of levels OBJPROP_LEVELS.
			\param  string aName - graphical object name,
         \param		int aValue - number of levels.
		*/  
      void SetLevels       (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_LEVELS,          aValue);}	

		/*!	
			Setting the level color OBJPROP_LEVELCOLOR.
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
         \param   color aValue - color value.
		*/   
      void SetLevelColor   (string aName,int aIndex,color aValue)             {ObjectSetInteger(0,aName,OBJPROP_LEVELCOLOR,      aIndex,aValue);}		

		/*!	
			Setting the level style OBJPROP_LEVELSTYLE.
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
         \param   ENUM_LINE_STYLE aValue - style value.
		*/  
      void SetLevelStyle   (string aName,int aIndex,ENUM_LINE_STYLE aValue)   {ObjectSetInteger(0,aName,OBJPROP_LEVELSTYLE,      aIndex,aValue);}

		/*!	
			Setting the level width OBJPROP_LEVELWIDTH.
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
         \param   int aValue - width value.
		*/  
      void SetLevelWidth   (string aName,int aIndex,int aValue)               {ObjectSetInteger(0,aName,OBJPROP_LEVELWIDTH,      aIndex,aValue);}		

		/*!	
			Setting the font size OBJPROP_FONTSIZE.
			\param  string aName - graphical object name,
         \param   int aValue - size value.
		*/  
      void SetFontSize     (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_FONTSIZE,        aValue);}		   

		/*!	
			Enabling the ray to the left OBJPROP_RAY_LEFT.
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/    
      void SetRayLeft      (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_RAY_LEFT,        aValue);} 	

		/*!	
			Enabling the ray to the right OBJPROP_RAY_RIGHT.
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/  
      void SetRayRight     (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_RAY_RIGHT,       aValue);} 		

		/*!	
			Enabling the extension of the vertical line in subwindows OBJPROP_RAY.
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/   
      void SetRay          (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_RAY,             aValue);} 		

		/*!	
			Enabling the display of a full ellipse in the "Fibonacci Arcs" object OBJPROP_ELLIPSE.
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (ellipse/arcs).
		*/ 
      void SetEllipse      (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_ELLIPSE,         aValue);} 			   

		/*!	
			Setting the arrow code OBJPROP_ARROWCODE.
			\param  string aName - graphical object name,
         \param   char aValue - arrow code.
		*/ 
      void SetArrowCode    (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_ARROWCODE,       aValue);}

		/*!	
			Setting the visibility of an object within the timeframes OBJPROP_TIMEFRAMES.
			\param  string aName - graphical object name,
         \param   long aValue - flag combination.
		*/   
      void SetTimeFrames   (string aName,long aValue)                         {ObjectSetInteger(0,aName,OBJPROP_TIMEFRAMES,      aValue);}

		/*!	
			Setting the anchor point OBJPROP_ANCHOR.
			\param  string aName - graphical object name,
         \param   long aValue - anchor point (ENUM_ARROW_ANCHOR or ENUM_ANCHORPOINT).
		*/   
      void SetAnchor       (string aName,long aValue)                         {ObjectSetInteger(0,aName,OBJPROP_ANCHOR,          aValue);}

		/*!	
			Setting the distance from the anchor corner along the X-axis OBJPROP_XDISTANCE.
			\param  string aName - graphical object name,
         \param   int aValue - distance value.
		*/   
      void SetXDistance    (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_XDISTANCE,       aValue);}	

		/*!	
			Setting the distance from the anchor corner along the Y-axis OBJPROP_YDISTANCE.
			\param  string aName - graphical object name,
         \param   int aValue - distance value.
		*/ 
      void SetYDistance    (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_YDISTANCE,       aValue);}	

		/*!	
			Setting the Gann object trend OBJPROP_DIRECTION.
			\param  string aName - graphical object name,
         \param   ENUM_GANN_DIRECTION aValue - trend value.
		*/ 
      void SetDirection    (string aName,ENUM_GANN_DIRECTION aValue)          {ObjectSetInteger(0,aName,OBJPROP_DIRECTION,       aValue);}

		/*!	
			Setting the Elliott Wave degree OBJPROP_DEGREE.
			\param  string aName - graphical object name,
         \param   ENUM_ELLIOT_WAVE_DEGREE aValue - degree value.
		*/ 
      void SetDegree       (string aName,ENUM_ELLIOT_WAVE_DEGREE aValue)      {ObjectSetInteger(0,aName,OBJPROP_DEGREE,          aValue);}

		/*!	
			Enabling the Elliott Wave grid lines OBJPROP_DRAWLINES.
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/ 
      void SetDrawLines    (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_DRAWLINES,       aValue);} 

		/*!	
			Setting the button state.
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (on/off).
		*/  
      void SetState        (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_STATE,           aValue);} 

		/*!	
			Setting the horizontal size OBJPROP_XSIZE.
			\param  string aName - graphical object name,
         \param   int aValue - size value.
		*/   
      void SetXSize        (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_XSIZE,           aValue);}	

		/*!	
			Setting the vertical size OBJPROP_YSIZE.
			\param  string aName - graphical object name,
         \param   int aValue - size value.
		*/  
      void SetYSize        (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_YSIZE,           aValue);}		

		/*!	
			Setting the X-coordinate of the beginning of the visibility area OBJPROP_XOFFSET.
			\param  string aName - graphical object name,
         \param   int aValue - coordinate value.
		*/ 
      void SetXOffset      (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_XOFFSET,         aValue);}	

		/*!	
			Setting the Y-coordinate of the beginning of the visibility area OBJPROP_YOFFSET.
			\param  string aName - graphical object name,
         \param   int aValue - coordinate value.
		*/ 
      void SetYOffset      (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_YOFFSET,         aValue);}	

		/*!	
			Setting the "Chart" object timeframe OBJPROP_PERIOD.
			\param  string aName - graphical object name,
         \param   ENUM_TIMEFRAMES aValue - timeframe value.
		*/ 
      void SetPeriod       (string aName,ENUM_TIMEFRAMES aValue)              {ObjectSetInteger(0,aName,OBJPROP_PERIOD,          aValue);}

		/*!	
			Enabling/disabling the "Chart" object date scale visibility OBJPROP_DATE_SCALE.
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/ 
      void SetDateScale    (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_DATE_SCALE,      aValue);} 

		/*!	
			Enabling/disabling the "Chart" object price scale visibility OBJPROP_PRICE_SCALE.
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/ 
      void SetPriceScale   (string aName,bool aValue)                         {ObjectSetInteger(0,aName,OBJPROP_PRICE_SCALE,     aValue);} 

		/*!	
			Setting the "Chart" object scale OBJPROP_CHART_SCALE.
			\param  string aName - graphical object name,
         \param   int aValue - value 1-5.
		*/  
      void SetChartScale   (string aName,int aValue)                          {ObjectSetInteger(0,aName,OBJPROP_CHART_SCALE,     aValue);}		

		/*!	
			Setting the background color OBJPROP_BGCOLOR.
			\param  string aName - graphical object name,
         \param   color aValue - color value.
		*/    
      void SetBgColor      (string aName,color aValue)                        {ObjectSetInteger(0,aName,OBJPROP_BGCOLOR,         aValue);}

		/*!	
			Setting the chart corner for binding OBJPROP_CORNER.
			\param  string aName - graphical object name,
         \param   ENUM_BASE_CORNER aValue - chart corner.
		*/  
      void SetCorner       (string aName,ENUM_BASE_CORNER aValue)             {ObjectSetInteger(0,aName,OBJPROP_CORNER,          aValue);}

		/*!	
			Setting the "Rectangle Frame" object border type OBJPROP_BORDER_TYPE.
			\param  string aName - graphical object name,
         \param   ENUM_BORDER_TYPE aValue - border type.
		*/   
      void SetBorderType   (string aName,ENUM_BORDER_TYPE aValue)             {ObjectSetInteger(0,aName,OBJPROP_BORDER_TYPE,     aValue);}      

		/*!	
			Setting the price value OBJPROP_PRICE.
			\param  string aName - graphical object name,
         \param   int aIndex - point number (from zero),
		 	\param  double aValue - value.
		*/  
      void SetPrice        (string aName,int aIndex,double aValue)            {ObjectSetDouble(0,aName,OBJPROP_PRICE,            aIndex,aValue);} 

		/*!	
			Setting the level value OBJPROP_LEVELVALUE.
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
		 	\param  double aValue - value.
		*/  
      void SetLevelValue   (string aName,int aIndex,double aValue)            {ObjectSetDouble(0,aName,OBJPROP_LEVELVALUE,       aIndex,aValue);}  

		/*!	
			Setting the scale (property of Gann objects and "Fibonacci Arcs" object) OBJPROP_SCALE.
			\param  string aName - graphical object name,
		 	\param  double aValue - scale value.
		*/ 
      void SetScale        (string aName,double aValue)                       {ObjectSetDouble(0,aName,OBJPROP_SCALE,            aValue);}     

		/*!	
			Setting the angle OBJPROP_ANGLE.
			\param  string aName - graphical object name,
		 	\param  double aValue - angle value OBJPROP_ANGLE.
		*/    
      void SetAngle        (string aName,double aValue)                       {ObjectSetDouble(0,aName,OBJPROP_ANGLE,            aValue);}

		/*!	
			Setting the standard deviation channel width OBJPROP_DEVIATION.
			\param  string aName - graphical object name,
		 	\param  double aValue - width value (number of standard deviations).
		*/   
      void SetDeviation    (string aName,double aValue)                       {ObjectSetDouble(0,aName,OBJPROP_DEVIATION,        aValue);}

		/*!	
			Setting the text OBJPROP_TEXT.
			\param  string aName - graphical object name,
		 	\param  string aValue - text.
		*/  
      void SetText         (string aName,string aValue)                       {ObjectSetString(0,aName,OBJPROP_TEXT,             aValue);}

		/*!	
			Setting the tooltip OBJPROP_TOOLTIP.
			\param  string aName - graphical object name,
		 	\param  string aValue - text.
		 	\remark Set value "\n" to disable the tooltip.		 	
		*/
      void SetToolTip      (string aName,string aValue)                       {ObjectSetString(0,aName,OBJPROP_TOOLTIP,          aValue);}

		/*!	
			Setting the level text OBJPROP_LEVELTEXT.
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
		 	\param  string aValue - text. 	
		*/  
      void SetLevelText    (string aName,int aIndex,string aValue)            {ObjectSetString(0,aName,OBJPROP_LEVELTEXT,        aIndex,aValue);} 

		/*!	
			Setting the font type OBJPROP_FONT.
			\param  string aName - graphical object name,
		 	\param  string aValue - font name. 	
		*/ 
      void SetFont         (string aName,string aValue)                       {ObjectSetString(0,aName,OBJPROP_FONT,             aValue);} 

		/*!	
			Setting the BMP file for "On" state OBJPROP_BMPFILE, modifier 0.
			\param  string aName - graphical object name,
		 	\param  string aValue - file name. 	
		*/  
      void SetBmpFileOn    (string aName,string aValue)                       {ObjectSetString(0,aName,OBJPROP_BMPFILE,          0,aValue);}       

		/*!	
			Setting the BMP file for "Off" state OBJPROP_BMPFILE, modifier 1.
			\param  string aName - graphical object name,
		 	\param  string aValue - file name. 	
		*/  
      void SetBmpFileOff   (string aName,string aValue)                       {ObjectSetString(0,aName,OBJPROP_BMPFILE,          1,aValue);}       

		/*!	
			Setting the "Chart" object symbol OBJPROP_SYMBOL.
			\param  string aName - graphical object name,
		 	\param  string aValue - symbol. 	
		*/  
      void SetSymbol       (string aName,string aValue)                       {ObjectSetString(0,aName,OBJPROP_SYMBOL,           aValue);}  
   
      //+------------------------------------------------------------------+
      //|   Getting the properties by the chart identifier and object name    |
      //+------------------------------------------------------------------+         
      
		/*!	
			Color OBJPROP_COLOR.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name. 
		 	\return  Color value (color type).		
		*/  
      color                   Color       (long aChartID,string aName)             {return( (color)                    ObjectGetInteger(aChartID,aName,OBJPROP_COLOR));}
		
		/*!	
			Style OBJPROP_STYLE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 			
		 	\return  Style value (ENUM_LINE_STYLE type).		
		*/        
      ENUM_LINE_STYLE         Style       (long aChartID,string aName)             {return( (ENUM_LINE_STYLE)          ObjectGetInteger(aChartID,aName,OBJPROP_STYLE));}
		
		/*!	
			Width OBJPROP_WIDTH.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Width value (int type).		
		*/        
      int                     Width       (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_WIDTH));} 
		
		/*!	
			Background position of an object OBJPROP_BACK.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - in the background, false - in the foreground.		
		*/          
      bool                    Back        (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_BACK));} 	
		
		/*!	
			Filling an object with a color OBJPROP_FILL (for OBJ_RECTANGLE, OBJ_TRIANGLE, OBJ_ELLIPSE, OBJ_CHANNEL, OBJ_STDDEVCHANNEL, OBJ_REGRESSION)
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - filled, false - outlined.	
		*/  
      bool                    Fill        (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_FILL));} 		
		
		/*!	
			Object selection OBJPROP_SELECTED.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - selected, false - not selected.	
		*/  
      bool                    Selected    (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_SELECTED));} 		
		
		/*!	
			The "Edit" object text editing option OBJPROP_SELECTED.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - editing not allowed, false - editing allowed.	
		*/  
      bool                    ReadOnly    (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_READONLY));} 		
		
		/*!	
			Object type OBJPROP_TYPE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 			
		 	\return  ENUM_OBJECT type.	
		*/  
      ENUM_OBJECT             Type        (long aChartID,string aName)             {return( (ENUM_OBJECT)              ObjectGetInteger(aChartID,aName,OBJPROP_TYPE));}
		
		/*!	
			Object anchor point time OBJPROP_TIME.
			\param   long aChartID - chart identifier,
         \param   string aName - graphical object name,
         \param   int aIndex - anchor point number (from zero).
		 	\return  Time value (datetime type).		
		*/  
      datetime                Time        (long aChartID,string aName,int aIndex)  {return( (datetime)                 ObjectGetInteger(aChartID,aName,OBJPROP_TIME,aIndex));}	
		
		/*!	
			Object selection option OBJPROP_SELECTABLE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 			
		 	\return  bool type. True - selection allowed, false - not allowed.	
		*/   
      bool                    Selectable  (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_SELECTABLE));} 		
		
		/*!	
			Object creation time OBJPROP_CREATETIME.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Time value (datetime type).		
		*/  
      datetime                CreateTime  (long aChartID,string aName)             {return( (datetime)                 ObjectGetInteger(aChartID,aName,OBJPROP_CREATETIME));}	
		
		/*!	
			Number of levels OBJPROP_LEVELS).
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Value (int type).		
		*/  
      int                     Levels      (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_LEVELS));}	
		
		/*!	
			Level color OBJPROP_LEVELCOLOR.
			\param  long aChartID - chart identifier,
         \param   int aIndex - level number (from zero).
         \param  string aName - graphical object name. 			         
		 	\return  Color value (color type).		
		*/ 
      color                   LevelColor  (long aChartID,string aName,int aIndex)  {return( (color)                    ObjectGetInteger(aChartID,aName,OBJPROP_LEVELCOLOR,aIndex));}		
		
		/*!	
			Level style OBJPROP_LEVELSTYLE.
			\param  long aChartID - chart identifier,
         \param   int aIndex - level number (from zero).
         \param  string aName - graphical object name. 			         
		 	\return  Style value (ENUM_LINE_STYLE type).		
		*/  
      ENUM_LINE_STYLE         LevelStyle  (long aChartID,string aName,int aIndex)  {return( (ENUM_LINE_STYLE)          ObjectGetInteger(aChartID,aName,OBJPROP_LEVELSTYLE,aIndex));}	
		
		/*!	
			Level width OBJPROP_LEVELWIDTH.
			\param  long aChartID - chart identifier,
         \param   int aIndex - level number (from zero).
         \param  string aName - graphical object name. 			         
		 	\return  Width value (int type).		
		*/  
      int                     LevelWidth  (long aChartID,string aName,int aIndex)  {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_LEVELWIDTH,aIndex));}		
		
		/*!	
			Font size OBJPROP_FONTSIZE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Size value (int type).		
		*/  
      int                     FontSize    (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_FONTSIZE));}		   
		
		/*!	
			Ray extension to the left OBJPROP_RAY_LEFT.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  bool type. True - ray to the left is present, false - no ray.		
		*/  
      bool                    RayLeft     (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_RAY_LEFT));} 	
		
		/*!	
			Ray extension to the right OBJPROP_RAY_RIGHT.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  bool type. True - ray to the right is present, false - no ray.		
		*/ 
      bool                    RayRight    (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_RAY_RIGHT));} 		
		
		/*!	
			Vertical line runs through all chart windows OBJPROP_RAY.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  bool type. True - runs through all chart windows, false - is confined to one subwindow.		
		*/  
      bool                    Ray         (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_RAY));} 		
		
		/*!	
			Display of a full ellipse in the "Fibonacci Arcs" object OBJPROP_ELLIPSE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  bool type. True - full ellipse, false - arcs.		
		*/ 
      bool                    Ellipse     (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_ELLIPSE));} 			   
		
		/*!	
			Arrow code for the "Arrow" object OBJPROP_ARROWCODE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Arrow code (char type).
		*/ 
      char                    ArrowCode   (long aChartID,string aName)             {return( (char)                     ObjectGetInteger(aChartID,aName,OBJPROP_ARROWCODE));}
		
		/*!	
			Visibility of an object within the timeframes OBJPROP_TIMEFRAMES.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Visibility flag set (long type).
		*/ 
      long                    TimeFrames  (long aChartID,string aName)             {return(                            ObjectGetInteger(aChartID,aName,OBJPROP_TIMEFRAMES));}
		
		/*!	
			Anchor point position OBJPROP_ANCHOR.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Anchor point value (long type). For OBJ_ARROW one of the ENUM_ARROW_ANCHOR values, for OBJ_LABEL and OBJ_TEXT - one of the ENUM_ANCHORPOINT values.
		*/ 
      long                    Anchor      (long aChartID,string aName)             {return(                            ObjectGetInteger(aChartID,aName,OBJPROP_ANCHOR));}
		
		/*!	
			Distance from the anchor corner along the X-axis in pixels OBJPROP_XDISTANCE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Value (int type).
		*/ 
      int                     XDistance   (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_XDISTANCE));}	
		
		/*!	
			Distance from the anchor corner along the Y-axis in pixels OBJPROP_YDISTANCE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Value (int type).
		*/  
      int                     YDistance   (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_YDISTANCE));}	
		
		/*!	
			Gann object trend OBJPROP_DIRECTION.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Value (ENUM_GANN_DIRECTION type).
		*/   
      ENUM_GANN_DIRECTION     Direction   (long aChartID,string aName)             {return( (ENUM_GANN_DIRECTION)      ObjectGetInteger(aChartID,aName,OBJPROP_DIRECTION));}
		
		/*!	
			Elliott Wave degree OBJPROP_DEGREE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Value (ENUM_ELLIOT_WAVE_DEGREE type).
		*/ 
      ENUM_ELLIOT_WAVE_DEGREE Degree      (long aChartID,string aName)             {return( (ENUM_ELLIOT_WAVE_DEGREE)  ObjectGetInteger(aChartID,aName,OBJPROP_DEGREE));}
		
		/*!	
			Elliott Wave grid lines display OBJPROP_DRAWLINES.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  bool type. True - enabled, false - disabled.		
		*/  
      bool                    DrawLines   (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_DRAWLINES));} 
		
		/*!	
			Button state (On/Off) OBJPROP_STATE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  bool type. True - on, false - off.
		*/ 
      bool                    State       (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_STATE));} 
		
		/*!	
			"Chart" object identifier OBJPROP_CHART_ID.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Identifier value (long type).
		*/ 
      long                    ChartChartID(long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_CHART_ID));}
		
		/*!	
			Horizontal size of an object OBJPROP_XSIZE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Size value (int type).
		*/   
      int                     XSize       (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_XSIZE));}	
		
		/*!	
			Vertical size of an object OBJPROP_YSIZE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Size value (int type).
		*/ 
      int                     YSize       (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_YSIZE));}		
		
		/*!	
			X-coordinate of the beginning of the object visibility area OBJPROP_XOFFSET.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Value (int type).
		*/ 
      int                     XOffset     (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_XOFFSET));}	
		
		/*!	
			Y-coordinate of the beginning of the object visibility area OBJPROP_YOFFSET.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Value (int type).
		*/ 
      int                     YOffset     (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_YOFFSET));}	
		
		/*!	
			"Chart" object timeframe OBJPROP_PERIOD.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Value (ENUM_TIMEFRAMES type).
		*/ 
      ENUM_TIMEFRAMES         Period      (long aChartID,string aName)             {return( (ENUM_TIMEFRAMES)          ObjectGetInteger(aChartID,aName,OBJPROP_PERIOD));}
		
		/*!	
			"Chart" object date scale display OBJPROP_DATE_SCALE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  bool type. True - scale is present, false - no scale.
		*/ 
      bool                    DateScale   (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_DATE_SCALE));} 
		
		/*!	
			"Chart" object price scale display OBJPROP_PRICE_SCALE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  bool type. True - scale is present, false - no scale.
		*/  
      bool                    PriceScale  (long aChartID,string aName)             {return( (bool)                     ObjectGetInteger(aChartID,aName,OBJPROP_PRICE_SCALE));} 
		
		/*!	
			"Chart" object scale OBJPROP_CHART_SCALE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
      	\return  Value 1-5 (int type).
		*/  
      int                     ChartScale  (long aChartID,string aName)             {return( (int)                      ObjectGetInteger(aChartID,aName,OBJPROP_CHART_SCALE));}		
		
		/*!	
			Background color OBJPROP_BGCOLOR.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Color value (color type).		
		*/  
      color                   BgColor     (long aChartID,string aName)             {return( (color)                    ObjectGetInteger(aChartID,aName,OBJPROP_BGCOLOR));}
		
		/*!	
			Chart corner for binding a graphical object OBJPROP_CORNER.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Value (ENUM_BASE_CORNER type).
		*/  
      ENUM_BASE_CORNER        Corner      (long aChartID,string aName)             {return( (ENUM_BASE_CORNER)         ObjectGetInteger(aChartID,aName,OBJPROP_CORNER));}
		
		/*!	
			"Rectangle Frame" object border type OBJPROP_BORDER_TYPE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Value (ENUM_BORDER_TYPE type).
		*/   
      ENUM_BORDER_TYPE        BorderType  (long aChartID,string aName)             {return( (ENUM_BORDER_TYPE)         ObjectGetInteger(aChartID,aName,OBJPROP_BORDER_TYPE));}
		
		/*!	
			Price coordinate OBJPROP_PRICE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name,			
         \param   int aIndex - point number (from zero).
		 	\return  Value (double type).
		*/ 
      double                  Price       (long aChartID,string aName,int aIndex)  {return(                            ObjectGetDouble(aChartID,aName,OBJPROP_PRICE,aIndex));} 
		
		/*!	
			Level value OBJPROP_LEVELVALUE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name,			
         \param   int aIndex - level number (from zero).
		 	\return  Value (double type).
		*/ 
      double                  LevelValue  (long aChartID,string aName,int aIndex)  {return(                            ObjectGetDouble(aChartID,aName,OBJPROP_LEVELVALUE,aIndex));}  
		
		/*!	
			Scale (property of Gann objects and "Fibonacci Arcs" object) OBJPROP_SCALE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Value (double type).
		*/ 
      double                  Scale       (long aChartID,string aName)             {return(                            ObjectGetDouble(aChartID,aName,OBJPROP_SCALE));}
		
		/*!	
			Angle OBJPROP_ANGLE.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Value (double type).
		*/ 
      double                  Angle       (long aChartID,string aName)             {return(                            ObjectGetDouble(aChartID,aName,OBJPROP_ANGLE));}
		
		/*!	
			Deviation for standard deviation channel OBJPROP_DEVIATION.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Value (double type).
		*/ 
      double                  Deviation   (long aChartID,string aName)             {return(                            ObjectGetDouble(aChartID,aName,OBJPROP_DEVIATION));}
		
		/*!	
			Object text OBJPROP_TEXT.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Text.
		*/  
      string                  Text        (long aChartID,string aName)             {return(                            ObjectGetString(aChartID,aName,OBJPROP_TEXT));}
		
		/*!	
			Tooltip text. OBJPROP_TOOLTIP.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Text.
		 	\remark Set value "\n" to disable the tooltip.
		*/  
      string                  ToolTip     (long aChartID,string aName)             {return(                            ObjectGetString(aChartID,aName,OBJPROP_TOOLTIP));}
		
		/*!	
			Level text. OBJPROP_LEVELTEXT.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name,		
         \param   int aIndex - level number (from zero).			
		 	\return  Text.
		*/ 
      string                  LevelText   (long aChartID,string aName,int aIndex)  {return(                            ObjectGetString(aChartID,aName,OBJPROP_LEVELTEXT,aIndex));} 
		
		/*!	
			Font name. OBJPROP_FONT.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Name (string type).
		*/   
      string                  Font        (long aChartID,string aName)             {return(                            ObjectGetString(aChartID,aName,OBJPROP_FONT));}
		
		/*!	
			BMP file for "On" state OBJPROP_BMPFILE, modifier 0.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  File name (string type).
		*/  
      string                  BmpFileOn   (long aChartID,string aName)             {return(                            ObjectGetString(aChartID,aName,OBJPROP_BMPFILE,0));}
		
		/*!	
			BMP file for "Off" state OBJPROP_BMPFILE, modifier 1.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  File name (string type).
		*/  
      string                  BmpFileOff  (long aChartID,string aName)             {return(                            ObjectGetString(aChartID,aName,OBJPROP_BMPFILE,1));}       
		
		/*!	
			"Chart" object symbol OBJPROP_SYMBOL.
			\param  long aChartID - chart identifier,
         \param  string aName - graphical object name. 						
		 	\return  Symbol (string type).
		*/  
      string                  Symbol      (long aChartID,string aName)             {return(                            ObjectGetString(aChartID,aName,OBJPROP_SYMBOL));}  
      
      //+------------------------------------------------------------------+
      //|   Setting the properties by the chart identifier and object name    |
      //+------------------------------------------------------------------+     

		/*!	
			Color setting OBJPROP_COLOR.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param		color aValue - color value.			
		*/  
      void SetColor        (long aChartID,string aName,color aValue)                        {ObjectSetInteger(aChartID,aName,OBJPROP_COLOR,           aValue);}
		/*!	
			Style setting OBJPROP_STYLE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param		ENUM_LINE_STYLE aValue - style value.			
		*/
      void SetStyle        (long aChartID,string aName,ENUM_LINE_STYLE aValue)              {ObjectSetInteger(aChartID,aName,OBJPROP_STYLE,           aValue);}
		
		/*!	
			Width setting OBJPROP_WIDTH.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param		int aValue - width value.			
		*/ 
      void SetWidth        (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_WIDTH,           aValue);} 
		
		/*!	
			Background/foreground position setting OBJPROP_BACK.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (background/foreground).
		*/ 
      void SetBack         (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_BACK,            aValue);} 	
		
		/*!	
			Enabling the color fill OBJPROP_FILL.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (filled/outlined).
		*/ 
      void SetFill         (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_FILL,            aValue);} 		
		
		/*!	
			Enabling the selection OBJPROP_SELECTED.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (selected/not selected).
		*/ 
      void SetSelected     (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_SELECTED,        aValue);} 		
		
		/*!	
			Enabling the text editing option in the "Edit" object OBJPROP_READONLY.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (allowed/not allowed).
		*/  
      void SetReadOnly     (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_READONLY,        aValue);} 		
		
		/*!	
			Setting the time of one of the anchor points OBJPROP_TIME.
			\param   long aChartID - chart identifier,
         \param   int aIndex - point number (from zero),
         \param   string aName - graphical object name,
         \param   datetime aValue - time value.
		*/    
      void SetTime         (long aChartID,string aName,int aIndex,datetime aValue)          {ObjectSetInteger(aChartID,aName,OBJPROP_TIME,            aIndex,aValue);}	
		
		/*!	
			Enabling the object selection option OBJPROP_SELECTABLE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param		bool aValue - true/false (allowed/not allowed).
		*/ 
      void SetSelectable   (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_SELECTABLE,      aValue);} 		
		
		/*!	
			Setting the number of levels OBJPROP_LEVELS.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param		int aValue - number of levels.
		*/  
      void SetLevels       (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_LEVELS,          aValue);}	
		
		/*!	
			Setting the level color OBJPROP_LEVELCOLOR.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
         \param   color aValue - color value.
		*/ 
      void SetLevelColor   (long aChartID,string aName,int aIndex,color aValue)             {ObjectSetInteger(aChartID,aName,OBJPROP_LEVELCOLOR,      aIndex,aValue);}		
		
		/*!	
			Setting the level style OBJPROP_LEVELSTYLE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
         \param   ENUM_LINE_STYLE aValue - style value.
		*/  
      void SetLevelStyle   (long aChartID,string aName,int aIndex,ENUM_LINE_STYLE aValue)   {ObjectSetInteger(aChartID,aName,OBJPROP_LEVELSTYLE,      aIndex,aValue);}
		
		/*!	
			Setting the level width OBJPROP_LEVELWIDTH.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
         \param   int aValue - width value.
		*/  
      void SetLevelWidth   (long aChartID,string aName,int aIndex,int aValue)               {ObjectSetInteger(aChartID,aName,OBJPROP_LEVELWIDTH,      aIndex,aValue);}		
		
		/*!	
			Setting the font size OBJPROP_FONTSIZE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValue - size value.
		*/  
      void SetFontSize     (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_FONTSIZE,        aValue);}		   
		
		/*!	
			Enabling the ray to the left OBJPROP_RAY_LEFT.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/   
      void SetRayLeft      (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_RAY_LEFT,        aValue);} 	
		
		/*!	
			Enabling the ray to the right OBJPROP_RAY_RIGHT.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/  
      void SetRayRight     (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_RAY_RIGHT,       aValue);} 		
		
		/*!	
			Enabling the extension of the vertical line in subwindows OBJPROP_RAY.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/ 
      void SetRay          (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_RAY,             aValue);} 		
		
		/*!	
			Enabling the display of a full ellipse in the "Fibonacci Arcs" object OBJPROP_ELLIPSE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (ellipse/arcs).
		*/ 
      void SetEllipse      (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_ELLIPSE,         aValue);} 			   
		
		/*!	
			Setting the arrow code OBJPROP_ARROWCODE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   char aValue - arrow code.
		*/ 
      void SetArrowCode    (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_ARROWCODE,       aValue);}
		
		/*!	
			Setting the visibility of an object within the timeframes OBJPROP_TIMEFRAMES.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   long aValue - flag combination.
		*/   
      void SetTimeFrames   (long aChartID,string aName,long aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_TIMEFRAMES,      aValue);}
		
		/*!	
			Setting the anchor point OBJPROP_ANCHOR.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   long aValue - anchor point (ENUM_ARROW_ANCHOR or ENUM_ANCHORPOINT).
		*/   
      void SetAnchor       (long aChartID,string aName,long aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_ANCHOR,          aValue);}
		
		/*!	
			Setting the distance from the anchor corner along the X-axis OBJPROP_XDISTANCE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValue - distance value.
		*/   
      void SetXDistance    (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_XDISTANCE,       aValue);}	
		
		/*!	
			Setting the distance from the anchor corner along the Y-axis OBJPROP_YDISTANCE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValue - distance value.
		*/ 
      void SetYDistance    (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_YDISTANCE,       aValue);}	
		
		/*!	
			Setting the Gann object trend OBJPROP_DIRECTION.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   ENUM_GANN_DIRECTION aValue - trend value.
		*/ 
      void SetDirection    (long aChartID,string aName,ENUM_GANN_DIRECTION aValue)          {ObjectSetInteger(aChartID,aName,OBJPROP_DIRECTION,       aValue);}
		
		/*!	
			Setting the Elliott Wave degree OBJPROP_DEGREE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   ENUM_ELLIOT_WAVE_DEGREE aValue - degree value.
		*/ 
      void SetDegree       (long aChartID,string aName,ENUM_ELLIOT_WAVE_DEGREE aValue)      {ObjectSetInteger(aChartID,aName,OBJPROP_DEGREE,          aValue);}
		
		/*!	
			Enabling the Elliott Wave grid lines OBJPROP_DRAWLINES.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/ 
      void SetDrawLines    (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_DRAWLINES,       aValue);} 
		
		/*!	
			Setting the button state.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (on/off).
		*/ 
      void SetState        (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_STATE,           aValue);} 
		
		/*!	
			Setting the horizontal size OBJPROP_XSIZE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValue - size value.
		*/ 
      void SetXSize        (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_XSIZE,           aValue);}	
		
		/*!	
			Setting the vertical size OBJPROP_YSIZE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValue - size value.
		*/  
      void SetYSize        (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_YSIZE,           aValue);}		
		
		/*!	
			Setting the X-coordinate of the beginning of the visibility area OBJPROP_XOFFSET.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValue - coordinate value.
		*/ 
      void SetXOffset      (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_XOFFSET,         aValue);}	
		
		/*!	
			Setting the Y-coordinate of the beginning of the visibility area OBJPROP_YOFFSET.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValue - coordinate value.
		*/ 
      void SetYOffset      (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_YOFFSET,         aValue);}	
		
		/*!	
			Setting the "Chart" object timeframe OBJPROP_PERIOD.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   ENUM_TIMEFRAMES aValue - timeframe value.
		*/ 
      void SetPeriod       (long aChartID,string aName,ENUM_TIMEFRAMES aValue)              {ObjectSetInteger(aChartID,aName,OBJPROP_PERIOD,          aValue);}
		
		/*!	
			Enabling/disabling the "Chart" object date scale visibility OBJPROP_DATE_SCALE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/ 
      void SetDateScale    (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_DATE_SCALE,      aValue);} 

		/*!	
			Enabling/disabling the "Chart" object price scale visibility OBJPROP_PRICE_SCALE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   bool aValue - true/false (enabled/disabled).
		*/ 
      void SetPriceScale   (long aChartID,string aName,bool aValue)                         {ObjectSetInteger(aChartID,aName,OBJPROP_PRICE_SCALE,     aValue);} 

		/*!	
			Setting the "Chart" object scale OBJPROP_CHART_SCALE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValue - value 1-5.
		*/  
      void SetChartScale   (long aChartID,string aName,int aValue)                          {ObjectSetInteger(aChartID,aName,OBJPROP_CHART_SCALE,     aValue);}		

		/*!	
			Setting the background color OBJPROP_BGCOLOR.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   color aValue - color value.
		*/    
      void SetBgColor      (long aChartID,string aName,color aValue)                        {ObjectSetInteger(aChartID,aName,OBJPROP_BGCOLOR,         aValue);}

		/*!	
			Setting the chart corner for binding OBJPROP_CORNER.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   ENUM_BASE_CORNER aValue - chart corner.
		*/  
      void SetCorner       (long aChartID,string aName,ENUM_BASE_CORNER aValue)             {ObjectSetInteger(aChartID,aName,OBJPROP_CORNER,          aValue);}

		/*!	
			Setting the "Rectangle Frame" object border type OBJPROP_BORDER_TYPE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   ENUM_BORDER_TYPE aValue - border type.
		*/  
      void SetBorderType   (long aChartID,string aName,ENUM_BORDER_TYPE aValue)             {ObjectSetInteger(aChartID,aName,OBJPROP_BORDER_TYPE,     aValue);}      

		/*!	
			Setting the price value OBJPROP_PRICE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aIndex - point number (from zero),
		 	\param  double aValue - value.
		*/  
      void SetPrice        (long aChartID,string aName,int aIndex,double aValue)            {ObjectSetDouble(aChartID,aName,OBJPROP_PRICE,            aIndex,aValue);} 

		/*!	
			Setting the level value OBJPROP_LEVELVALUE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
		 	\param  double aValue - value.
		*/  
      void SetLevelValue   (long aChartID,string aName,int aIndex,double aValue)            {ObjectSetDouble(aChartID,aName,OBJPROP_LEVELVALUE,       aIndex,aValue);}  

		/*!	
			Setting the scale (property of Gann objects and "Fibonacci Arcs" object) OBJPROP_SCALE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
		 	\param  double aValue - scale value.
		*/ 
      void SetScale        (long aChartID,string aName,double aValue)                       {ObjectSetDouble(aChartID,aName,OBJPROP_SCALE,            aValue);}     

		/*!	
			Setting the angle OBJPROP_ANGLE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
		 	\param  double aValue - angle value OBJPROP_ANGLE.
		*/   
      void SetAngle        (long aChartID,string aName,double aValue)                       {ObjectSetDouble(aChartID,aName,OBJPROP_ANGLE,            aValue);}

		/*!	
			Setting the standard deviation channel width OBJPROP_DEVIATION.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
		 	\param  double aValue - width value (number of standard deviations).
		*/ 
      void SetDeviation    (long aChartID,string aName,double aValue)                       {ObjectSetDouble(aChartID,aName,OBJPROP_DEVIATION,        aValue);}

		/*!	
			Setting the text OBJPROP_TEXT.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
		 	\param  string aValue - text.
		*/ 
      void SetText         (long aChartID,string aName,string aValue)                       {ObjectSetString(aChartID,aName,OBJPROP_TEXT,             aValue);}

		/*!	
			Setting the tooltip OBJPROP_TOOLTIP.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
		 	\param  string aValue - text.
		 	\remark Set value "\n" to disable the tooltip.		 	
		*/
      void SetToolTip      (long aChartID,string aName,string aValue)                       {ObjectSetString(aChartID,aName,OBJPROP_TOOLTIP,          aValue);}

		/*!	
			Setting the level text OBJPROP_LEVELTEXT.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aIndex - level number (from zero),
		 	\param  string aValue - text. 	
		*/  
      void SetLevelText    (long aChartID,string aName,int aIndex,string aValue)            {ObjectSetString(aChartID,aName,OBJPROP_LEVELTEXT,        aIndex,aValue);} 

		/*!	
			Setting the font type OBJPROP_FONT.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
		 	\param  string aValue - font name. 	
		*/ 
      void SetFont         (long aChartID,string aName,string aValue)                       {ObjectSetString(aChartID,aName,OBJPROP_FONT,             aValue);} 

		/*!	
			Setting the BMP file for "On" state OBJPROP_BMPFILE, modifier 0.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
		 	\param  string aValue - file name. 	
		*/  
      void SetBmpFileOn    (long aChartID,string aName,string aValue)                       {ObjectSetString(aChartID,aName,OBJPROP_BMPFILE,          0,aValue);}       

		/*!	
			Setting the BMP file for "Off" state OBJPROP_BMPFILE, modifier 1.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
		 	\param  string aValue - file name. 	
		*/  
      void SetBmpFileOff   (long aChartID,string aName,string aValue)                       {ObjectSetString(aChartID,aName,OBJPROP_BMPFILE,          1,aValue);}       

		/*!	
			Setting the "Chart" object symbol OBJPROP_SYMBOL.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
		 	\param  string aValue - symbol. 	
		*/  
      void SetSymbol       (long aChartID,string aName,string aValue)                       {ObjectSetString(aChartID,aName,OBJPROP_SYMBOL,           aValue);}  

      //+------------------------------------------------------------------+
      //|   Other methods                                                  |
      //+------------------------------------------------------------------+         

      // === Deletion ===

		/*!	
			Deletion of the attached object.
		*/ 
      void Delete(){ObjectDelete(m_id,m_name);} 
		
		/*!	
			Deletion of an object by name.
			\param  string aName - graphical object name.
		*/       
      void Delete(string aName){ObjectDelete(0,aName);} 
		
		/*!	
			Deletion of an object by the chart identifier and name.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name.
		*/       
      void Delete(long aChartID,string aName){ObjectDelete(aChartID,aName);} 

      // === Moving ===

		/*!	
			Moving the attached object.
			\param   int aIndex - point number (from zero),
			\param   datetime aTime  - time value,
			\param   double aPrice - vertical value.
		*/ 
      void Move(int aIndex,datetime aTime,double aPrice){
         ObjectMove(m_id,m_name,aIndex,aTime,aPrice);   
      }
      
		/*!	
			Moving an object by name.
			\param  string aName - graphical object name,
			\param   int aIndex - point number (from zero),
			\param   datetime aTime  - time value,
			\param   double aPrice - vertical value.			
		*/         
      void Move(string aName,int aIndex,datetime aTime,double aPrice){
         ObjectMove(0,aName,aIndex,aTime,aPrice);   
      }    
      
		/*!	
			Moving by the chart identifier and name.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
			\param   int aIndex - point number (from zero),
			\param   datetime aTime  - time value,
			\param   double aPrice - vertical value.			
		*/           
      void Move(long aChartID,string aName,int aIndex,datetime aTime,double aPrice){
         ObjectMove(aChartID,aName,aIndex,aTime,aPrice);   
      }
      
      // === Search ===
           
		/*!	
			Searching for the attached object.
			\return  Subwindow number, -1 if the object does not exist (int type). 
		*/ 
      int Find(){
         return(ObjectFind(m_id,m_name));
      }  
      
		/*!	
			Searching for an object by name.
			\param  string aName - graphical object name.
			\return  Subwindow number, -1 if the object does not exist (int type). 
		*/              
      int Find(string aName){
         return(ObjectFind(0,aName));
      }    
      
		/*!	
			Searching for an object by the chart identifier and name.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name.
			\return  Subwindow number, -1 if the object does not exist (int type). 
		*/         
      int Find(long aChartID,string aName){
         return(ObjectFind(aChartID,aName));
      }   
      
      // === Getting the time by value ===
      
		/*!	
			Getting the time by value for the attached object.
			\param  double aValue - value,
			\param  int aLineID - line number (from zero).
			\return  Time (datetime type). 
		*/ 
      datetime GetTimeByValue(double aValue,int aLineID=0){
         return(ObjectGetTimeByValue(m_id,m_name,aValue,aLineID));
      }         
      
		/*!	
			Getting the time by value and object name.
			\param  string aName - graphical object name,
			\param  double aValue - value,
			\param  int aLineID - line number (from zero).
			\return  Time (datetime type). 
		*/       
      datetime GetTimeByValue(string aName,double aValue,int aLineID=0){
         return(ObjectGetTimeByValue(0,aName,aValue,aLineID));
      }    

		/*!	
			Getting the time by value and the chart identifier and object name.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,			
			\param  double aValue - value,
			\param  int aLineID - line number (from zero).
			\return  Time (datetime type). 
		*/ 	      
      datetime GetTimeByValue(long aChartID,string aName,double aValue,int aLineID=0){
         return(ObjectGetTimeByValue(aChartID,aName,aValue,aLineID));
      }   

      // === Getting the value by time ===
      
		/*!	
			Getting the value by time for the attached object.
			\param  datetime aTime - time,
			\param  int aLineID - line number (from zero).
			\return Value (double type). 
		*/ 
      double GetValueByTime(datetime aTime,int aLineID=0){
         return(ObjectGetValueByTime(m_id,m_name,aTime,aLineID));
      }   
      
		/*!	
			Getting the value by time and name.
			\param  string aName - graphical object name,	
			\param  datetime aTime - time,
			\param  int aLineID - line number (from zero).
			\return Value (double type). 
		*/             
      double GetValueByTime(string aName,datetime aTime,int aLineID=0){
         return(ObjectGetValueByTime(0,aName,aTime,aLineID));
      }
          
		/*!	
			Getting the value by time and by the chart identifier and object name.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,	
			\param  datetime aTime - time,
			\param  int aLineID - line number (from zero).
			\return Value (double type). 
		*/         
      double GetValueByTime(long aChartID,string aName,datetime aTime,int aLineID=0){
         return(ObjectGetValueByTime(aChartID,aName,aTime,aLineID));
      } 
      

      // === === === === ===
   
      /*!
         Total graphical objects.   
         \param   aChartID=0 - chart identifier,
         \param   int aSubWindow=-1 - subwindow number,
         \param   int aType=-1 - object type.
      */      
      int Total(int aChartID=0,int aSubWindow=-1,int aType=-1){
         return(ObjectsTotal(aChartID,aSubWindow,aType));
      }   
      
      /*!
         Update of a chart to which the object is attached.   
      */ 
      void Redraw(){
         ChartRedraw(m_id);
      }  
      /*!
         Update of the specified chart.  
         \param long aChartID - chart identifier. 
      */              
      void Redraw(long aChartID){
         ChartRedraw(aChartID);
      }         
          
      // === v2 ===
        
		/*!	
			Simultaneous setting of distance from the anchor corner along the X-axis (OBJPROP_XDISTANCE) and the Y-axis (OBJPROP_YDISTANCE).
         \param   int aValueX - X distance value,
         \param   int aValueY - Y distance value.
		*/   
      void SetXYDistance(int aValueX,int aValueY){
         ObjectSetInteger(m_id,m_name,OBJPROP_XDISTANCE,aValueX);
         ObjectSetInteger(m_id,m_name,OBJPROP_YDISTANCE,aValueY);
      }

		/*!	
			Simultaneous setting of distance from the anchor corner along the X-axis (OBJPROP_XDISTANCE) and the Y-axis (OBJPROP_YDISTANCE).
			\param  string aName - graphical object name,
         \param   int aValueX - X distance value,
         \param   int aValueY - Y distance value.
		*/  
      void SetXYDistance(string aName,int aValueX,int aValueY){
         ObjectSetInteger(0,aName,OBJPROP_XDISTANCE,aValueX);
         ObjectSetInteger(0,aName,OBJPROP_YDISTANCE,aValueY);
      }         	

		/*!	
			Simultaneous setting of distance from the anchor corner along the X-axis (OBJPROP_XDISTANCE) and the Y-axis (OBJPROP_YDISTANCE).
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValueX - X distance value,
         \param   int aValueY - Y distance value.
		*/  
      void SetXYDistance(long aChartID,string aName,int aValueX,int aValueY){
         ObjectSetInteger(aChartID,aName,OBJPROP_XDISTANCE,aValueX);
         ObjectSetInteger(aChartID,aName,OBJPROP_YDISTANCE,aValueY);         
      }

       
		/*!	
			Simultaneous setting of sizes OBJPROP_XSIZE and OBJPROP_YSIZE.
         \param   int aValueX - X size value,
         \param   int aValueY - Y size value.         
		*/       
      void SetXYSize(int aValueX,int aValueY){
         ObjectSetInteger(m_id,m_name,OBJPROP_XSIZE,aValueX);
         ObjectSetInteger(m_id,m_name,OBJPROP_YSIZE,aValueY);         
      }	
      
		/*!	
			Simultaneous setting of sizes OBJPROP_XSIZE and OBJPROP_YSIZE.
			\param  string aName - graphical object name,
         \param   int aValueX - X size value,
         \param   int aValueY - Y size value.         
		*/       
      void SetXYSize(string aName,int aValueX,int aValueY){
         ObjectSetInteger(0,aName,OBJPROP_XSIZE,aValueX);
         ObjectSetInteger(0,aName,OBJPROP_YSIZE,aValueY);         
      }	      
      
		/*!	
			Simultaneous setting of sizes OBJPROP_XSIZE and OBJPROP_YSIZE.
			\param  long aChartID - chart identifier,
			\param  string aName - graphical object name,
         \param   int aValueX - X size value,
         \param   int aValueY - Y size value.         
		*/       
      void SetXYSize(long aChartID,string aName,int aValueX,int aValueY){
         ObjectSetInteger(aChartID,aName,OBJPROP_XSIZE,aValueX);
         ObjectSetInteger(aChartID,aName,OBJPROP_YSIZE,aValueY);         
      }	 
};

CGraphicObjectShell g;

//+------------------------------------------------------------------+
//|                                                                  |
//|         CWorkPiece CLASS                                         |
//|                                                                  |
//+------------------------------------------------------------------+

/*!
	\brief   A quick creation of graphical objects with specification of properties in the parameters.
	
	\details The class contains methods for a quick creation of graphical objects with specified
	         properties by a single code line. Properties of an object under creation 
	         are specified in the parameters when calling the creation methods.

   \remark	The class has already been declared in the file with name "w".
*/  

class CWorkPiece{
   public:
		/*!	
			Rectangle label.
            \param		string aName="Canvas" - name,
            \param		int aSubWindow=0 - subwindow,
            \param		int aLeft=100 - position from the left side of the chart,
            \param		int aTop=100 - position from the top side of the chart,
            \param		int aWidth=300 - width,
            \param		int aHeight=150 - height,
            \param		color aColorBg=clrIvory - background color,
            \param		int aColorBorder=clrDimGray - border color.
            \remark	   Anchor point - top left corner.
		*/
      void Canvas(string aName="Canvas",int aSubWindow=0,int aLeft=100,int aTop=100,int aWidth=300,int aHeight=150,color aColorBg=clrIvory,int aColorBorder=clrDimGray){
         g.CreateRectangleLabel(aName,aSubWindow); // Rectangle label creation
         g.SetXDistance(aLeft); // Setting the X-coordinate
         g.SetYDistance(aTop); // Setting the Y-coordinate
         g.SetXSize(aWidth); // Setting the width
         g.SetYSize(aHeight); // Setting the height
         g.SetBgColor(aColorBg); // Setting the background color
         g.SetColor(aColorBorder); // Setting the border color
         g.SetCorner(CORNER_LEFT_UPPER); // Setting the anchor point
         g.SetBorderType(BORDER_FLAT); // Setting the border type
         g.SetTimeFrames(OBJ_ALL_PERIODS); // Setting visibility within all timeframes
         g.SetSelected(false); // Disabling the selection
         g.SetSelectable(false); // Disabling the object selection option
         g.SetWidth(1); // Setting the border width
         g.SetStyle(STYLE_SOLID); // Setting the border style
      }

		/*!	
			Label.
            \param		string aName="Label" - name,
            \param		int aSubWindow=0 - subwindow,
            \param		int aLeft=100 - position from the left side of the chart,
            \param      int aTop=100 - position from the top side of the chart,
            \param      string aText="Label" - text,
            \param      int aColor=clrDimGray - color,
            \param      int aFontSize=8 - font size,
            \param      string aFont="Arial" - font.
            \remark	   Anchor point - top left corner.
		*/
      void Label(string aName="Label",int aSubWindow=0,int aLeft=100,int aTop=100,string aText="Label",int aColor=clrDimGray,int aFontSize=8,string aFont="Arial"){
         g.CreateLabel(aName,aSubWindow);
         g.SetXDistance(aLeft);
         g.SetYDistance(aTop);
         g.SetText(aText);
         g.SetColor(aColor);
         g.SetFontSize(aFontSize);
         g.SetFont(aFont);
         g.SetCorner(CORNER_LEFT_UPPER);
         g.SetAnchor(ANCHOR_LEFT_UPPER);         
         g.SetSelected(false);
         g.SetSelectable(false);
      }  
      
		/*!	
			Button.
            \param		string aName="Button" - name,
            \param		int aSubWindow=0 - subwindow,
            \param		int aLeft=100 - position from the left side of the chart,
            \param		int aTop=100 - position from the top side of the chart,
            \param		int aWidth=40 - width,
            \param		int aHeight=15 - height,
            \param		string aText="Button" - caption text,
            \param		color aColorBg=clrSilver - button color,
            \param		color aColorText=clrBlack - text color,
            \param		int aFontSize=7 - caption font size,
            \param		string aFont="Arial" - caption font.
            \remark	   Anchor point - top left corner.
 		*/
      void Button(string aName="Button",int aSubWindow=0,int aLeft=100,int aTop=100,int aWidth=40,int aHeight=15,string aText="Button",color aColorBg=clrSilver,color aColorText=clrBlack,int aFontSize=7,string aFont="Arial"){
         g.CreateButton(aName,aSubWindow);
         g.SetXDistance(aLeft);
         g.SetYDistance(aTop);
         g.SetXSize(aWidth);
         g.SetYSize(aHeight);
         g.SetText(aText);
         g.SetColor(aColorText);
         g.SetBgColor(aColorBg);
         g.SetFontSize(aFontSize);
         g.SetFont(aFont);
         g.SetCorner(CORNER_LEFT_UPPER);
         g.SetSelected(false);
         g.SetSelectable(false);
      } 
      
		/*!	
			Edit.
            \param		string aName="Edit" - name,
            \param		int aSubWindow=0 - subwindow,
            \param		int aLeft=100 - position from the left side of the chart,
            \param		int aTop=100 - position from the top side of the chart,
            \param		int aWidth=40 - width,
            \param		int aHeight=15 - height,
            \param		string aText="Edit" - text,
            \param		color aColorBg=clrSnow - background color,
            \param		color aColorText=clrDimGray - text and border color,
            \param		int aFontSize=7 - font size,
            \param		string aFont="Arial" - font.			
            \remark	   Anchor point - top left corner.
 		*/
      void Edit(string aName="Edit",int aSubWindow=0,int aLeft=100,int aTop=100,int aWidth=40,int aHeight=15,string aText="Edit",color aColorBg=clrSnow,color aColorText=clrDimGray,int aFontSize=7,string aFont="Arial"){
         g.CreateEdit(aName,aSubWindow);
         g.SetXDistance(aLeft);
         g.SetYDistance(aTop);
         g.SetXSize(aWidth);
         g.SetYSize(aHeight);
         g.SetText(aText);
         g.SetColor(aColorText);
         g.SetBgColor(aColorBg);
         g.SetFontSize(aFontSize);
         g.SetFont(aFont);
         g.SetCorner(CORNER_LEFT_UPPER);
         g.SetSelected(false);
         g.SetSelectable(false);
         g.SetReadOnly(false);
      } 
      
		/*!	
			Frame with a caption.
            \param		string aName="Frame" - name,
            \param		int aSubWindow=0 - subwindow,
            \param		int aLeft=100 - position from the left side of the chart,
            \param		int aTop=100 - position from the top side of the chart,
            \param		int aWidth=50 - width,
            \param		int aHeight=50 - height,
            \param		string aCaption="Frame" - caption text,
            \param		int aCaptionWidth=31 - caption width,
            \param		color aColorBg=clrIvory - background color,
            \param		color aColorBorder=clrDimGray - border color,
            \param		color aColorCaption=clrDimGray - caption color.
            \remark	   Anchor point - top left corner.
            \remark	   The frame consists of graphical objects, as follows:  OBJ_RECTANGLE_LABEL (2 pcs.) and 
                        OBJ_LABEL. One rectangle label is the main one, the other one covers the frame 
                        under the caption. The frame can also be created without a caption, if the value of 
                        the aCaption parameter is "", whereby the frame consists of one rectangle label. 
                        Names of all graphical objects start with aName. In order to create 
                        a name for the main rectangle label,  "_Frame" text is added to aName, 
                        "_FrameL" is added for the caption name, "_FrameC" is added for the label covering the frame under the caption. 
 		*/
      void Frame(string aName="Frame",int aSubWindow=0,int aLeft=100,int aTop=100,int aWidth=50,int aHeight=50,string aCaption="Frame",int aCaptionWidth=31,color aColorBg=clrIvory,color aColorBorder=clrDimGray,color aColorCaption=clrDimGray){
         Canvas(aName+"_Frame",aSubWindow,aLeft,aTop,aWidth,aHeight,aColorBg,aColorBorder);
            if(aCaption!=""){
               Canvas(aName+"_FrameC",aSubWindow,aLeft+4,aTop,aCaptionWidth,1,aColorBg,aColorBg);
               Label(aName+"_FrameL",aSubWindow,aLeft+6,aTop-5,aCaption,aColorCaption,7,"Arial");
            }               
      }
      
		/*!	
			Deletion of a frame with a caption.
         \param   string aName="Frame" - name.
 		*/
      void FrameDelete(string aName="Frame"){
         ObjectDelete(0,aName+"_Frame");
         ObjectDelete(0,aName+"_FrameC");
         ObjectDelete(0,aName+"_FrameL");         
      }  
           
		/*!	
			Deletion of a graphical object by name in the "custom" chart.
         \param   string aName="Frame" - name.
 		*/
      void Delete(string aName){
         ObjectDelete(0,aName);
      }   
         
		/*!	
			Redrawing of the "custom" chart.
 		*/
      void Redraw(){
         ChartRedraw(0);
      }         
};

CWorkPiece w;

//+------------------------------------------------------------------+
//|                                                                  |
//|         CColorSchemes Class                                      |
//|                                                                  |
//+------------------------------------------------------------------+

/*!
	\brief   Set of color schemes.
	
	\details This class is intended for getting the color of the set color scheme by
	         its index.

   \remark	The class has already been declared in the file with name "ClrScheme".
*/   

class CColorSchemes{
   private:
      int m_ShemeIndex;
   public:
   		/*!	
   			Color scheme selection.
               \param		int aShemeIndex - color scheme index.
   		*/   
         void SetScheme(int aShemeIndex){ // Setting the color scheme number
            m_ShemeIndex=aShemeIndex;
         }
   		/*!	
   			Getting the color by its index.
               \param		int aColorIndex - color index in a scheme.
               \return		Color value.
   		*/          
         color Color(int aColorIndex){ 
            color m_Color[7][55];  // First measure - number of color schemes, second measure - color number in a scheme
            // === default ===
               // CInputBox
               m_Color[0][0]=clrSnow;           // Text box background color
               m_Color[0][1]=clrDimGray;        // Text and border color of the text box
               m_Color[0][2]=clrDimGray;        // Caption color
               m_Color[0][3]=clrPink;           // Warning color          
               // CSpinInputBox (additional, the remaining are identical to the ones in CInputBox)
               m_Color[0][4]=clrSilver;         // Button color
               m_Color[0][5]=clrLightGray;      // Flashing color
               // CVScrollBar, CHScrollBar (independent colors)
               m_Color[0][6]=clrDimGray;        // Border color
               m_Color[0][7]=clrLightGray;      // Bar colors
               m_Color[0][8]=clrSilver;         // Button color
               m_Color[0][9]=clrPink;           // Warning color
               m_Color[0][10]=clrDimGray;       // Caption (arrow) color
               m_Color[0][11]=clrSnow;          // Selected scroll box color
               m_Color[0][12]=clrLightGray;     // Flashing button color
               m_Color[0][13]=clrGainsboro;     // Flashing scroll box color
               // CCheckBox, CRadioGroup use the colors of CInputBox (except for warning color which is absent in CCheckBox, CRadioGroup)
               // CList - background and text colors are taken from CInputBox, but the selection color is of its own
               m_Color[0][14]=clrPaleTurquoise; // Selected item color
               // CHMenu, CVMenu
               m_Color[0][15]=clrWhiteSmoke;    // Color of the background with selected items
               m_Color[0][16]=clrGainsboro;     // Color of the background without selected items
               m_Color[0][17]=clrRed;           // Tick color
               // CHProgress
               m_Color[0][18]=clrLightGray;     // Background color   
               m_Color[0][19]=clrDimGray;       // Frame color
               m_Color[0][20]=clrLightSkyBlue;  // Bar color
               m_Color[0][21]=clrDimGray;       // Caption color
               // CDialer
               m_Color[0][22]=clrLightGray;     // Background color
               m_Color[0][23]=clrDimGray;       // Border color
               m_Color[0][24]=clrWhiteSmoke;    // Number button color
               m_Color[0][25]=clrDimGray;       // Caption color
               m_Color[0][26]=clrMistyRose;     // Cancel button color
               m_Color[0][27]=clrPaleGreen;     // OK button color
               m_Color[0][28]=clrPaleTurquoise; // Close button color
               m_Color[0][29]=clrSnow;          // Text box background color
               m_Color[0][30]=clrDimGray;       // Text color of the text box
               m_Color[0][31]=clrPink;          // Warning color 
               // CForm
               m_Color[0][32]=clrWhiteSmoke;    // Main color of the field for controls
               m_Color[0][33]=clrDimGray;       // Border color
               m_Color[0][34]=clrSilver;        // Button color
               m_Color[0][35]=clrBlack;         // Button caption color
               m_Color[0][36]=C'27,63,169';     // Top bar color
               m_Color[0][37]=clrGray;          // Bottom bar color
               m_Color[0][38]=clrYellow;        // Top bar caption color 
               // CFrame
               m_Color[0][39]=clrWhiteSmoke;    // Background
               m_Color[0][40]=clrDimGray;       // Border
               m_Color[0][41]=clrDimGray;       // Caption
               // CButtom
               m_Color[0][42]=clrSilver;        // Button color
               m_Color[0][43]=C'70,70,70';      // Button caption color      
               // CLabel
               m_Color[0][44]=clrDimGray;        // Caption color               
               // CCalendar
               m_Color[0][45]=clrWhiteSmoke;    // Background color
               m_Color[0][46]=clrDimGray;       // Frame color
               m_Color[0][47]=clrSilver;        // Buttons color
               m_Color[0][48]=clrDimGray;       // Buttons labels colors   
               m_Color[0][49]=clrDimGray;       // Labels color
               m_Color[0][50]=clrLightBlue;
               m_Color[0][51]=clrSnow;          // Calendar days color
               m_Color[0][52]=clrGainsboro;     // Previous and next month days color
               m_Color[0][53]=clrPink;          // Selected day color  
               m_Color[0][54]=clrRed;           // Current day frame color
               
                        
            // === yellow-brown ===
            
               m_Color[1][0]=clrLightYellow;    // Text box background color
               m_Color[1][1]=clrBrown;          // Text and border color of the text box
               m_Color[1][2]=clrBrown;          // Caption color
               m_Color[1][3]=clrLightPink;      // Warning color          
               // CSpinInputBox (additional, the remaining are identical to the ones in CInputBox)
               m_Color[1][4]=clrBurlyWood;      // Button color
               m_Color[1][5]=clrNavajoWhite;    // Flashing color
               // CVScrollBar, CHScrollBar (independent colors)
               m_Color[1][6]=clrBrown;          // Border color
               m_Color[1][7]=clrNavajoWhite;    // Bar colors
               m_Color[1][8]=clrBurlyWood;      // Button color
               m_Color[1][9]=clrPink;           // Warning color
               m_Color[1][10]=clrBrown;         // Caption (arrow) color
               m_Color[1][11]=clrLightYellow;   // Selected scroll box color
               m_Color[1][12]=clrLightYellow;   // Flashing button color
               m_Color[1][13]=clrLightYellow;   // Flashing scroll box color
               // CCheckBox, CRadioGroup use the colors of CInputBox (except for warning color which is absent in CCheckBox, CRadioGroup)
               // CList - background and text colors are taken from CInputBox, but the selection color is of its own
               m_Color[1][14]=clrBisque; // Selected item color
               // CHMenu, CVMenu
               m_Color[1][15]=clrLightYellow;   // Color of the background with selected items
               m_Color[1][16]=clrNavajoWhite;   // Color of the background without selected items
               m_Color[1][17]=clrRed;           // Tick color
               // CHProgress
               m_Color[1][18]=clrNavajoWhite;   // Background color   
               m_Color[1][19]=clrBrown;         // Border color
               m_Color[1][20]=clrOrange;        // Bar color
               m_Color[1][21]=clrBrown;         // Caption color
               // CDialer
               m_Color[1][22]=clrBurlyWood;     // Background color
               m_Color[1][23]=clrBrown;         // Border color
               m_Color[1][24]=clrBisque;        // Number button color
               m_Color[1][25]=clrBrown;         // Caption color
               m_Color[1][26]=clrLightPink;     // Cancel button color
               m_Color[1][27]=clrLightGreen;    // OK button color
               m_Color[1][28]=clrPaleTurquoise; // Close button color
               m_Color[1][29]=clrLightYellow;   // Text box background color
               m_Color[1][30]=clrBrown;         // Text color of the text box
               m_Color[1][31]=clrPink;          // Warning color  
               // CForm
               m_Color[1][32]=C'255,245,205';   // Main color of the field for controls
               m_Color[1][33]=clrSienna;        // Border color
               m_Color[1][34]=C'240,214,151';   // Button color
               m_Color[1][35]=C'116,60,33';     // Button caption color
               m_Color[1][36]=C'116,60,33';     // Top bar color
               m_Color[1][37]=C'116,60,33';     // Bottom bar color
               m_Color[1][38]=C'250,241,220';   // Top bar caption color 
               // CFrame
               m_Color[1][39]=C'255,245,205';   // Background
               m_Color[1][40]=clrBrown;         // Border
               m_Color[1][41]=clrBrown;         // Caption
               // CButtom
               m_Color[1][42]=clrBurlyWood;     // Button color
               m_Color[1][43]=clrMaroon;        // Button caption color                   
               // CLabel
               m_Color[1][44]=clrBrown;         // Caption color
               // CCalendar    
               m_Color[1][45]=clrLightYellow;   // Background color 
               m_Color[1][46]=clrBrown;         // Frame color
               m_Color[1][47]=clrBurlyWood;     // Buttons color
               m_Color[1][48]=clrBrown;         // Buttons labels color   
               m_Color[1][49]=clrBrown;         // Labels color
               m_Color[1][50]=clrGold;
               m_Color[1][51]=C'255,255,240';   // Calendar days color
               m_Color[1][52]=C'220,220,150';   // Previous and next month days color
               m_Color[1][53]=clrPink;          // Selected day color  
               m_Color[1][54]=clrRed;           // Current day frame color
               
               // === blue ===
               
               m_Color[2][0]=clrAliceBlue;      // Text box background color
               m_Color[2][1]=clrNavy;           // Text and border color of the text box
               m_Color[2][2]=clrNavy;           // Caption color
               m_Color[2][3]=clrLightPink;      // Warning color          
               // CSpinInputBox (additional, the remaining are identical to the ones in CInputBox)
               m_Color[2][4]=clrLightSteelBlue; // Button color
               m_Color[2][5]=clrAliceBlue;      // Flashing color
               // CVScrollBar, CHScrollBar (independent colors)
               m_Color[2][6]=clrNavy;           // Border color
               m_Color[2][7]=clrLightBlue;      // Bar colors
               m_Color[2][8]=clrLightSteelBlue; // Button color
               m_Color[2][9]=clrLightPink;      // Warning color
               m_Color[2][10]=clrNavy;          // Caption (arrow) color
               m_Color[2][11]=clrAliceBlue;     // Selected scroll box color
               m_Color[2][12]=clrAliceBlue;     // Flashing button color
               m_Color[2][13]=clrAliceBlue;     // Flashing scroll box color
               // CCheckBox, CRadioGroup use the colors of CInputBox (except for warning color which is absent in CCheckBox, CRadioGroup)
               // CList - background and text colors are taken from CInputBox, but the selection color is of its own
               m_Color[2][14]=clrPaleTurquoise; // Selected item color
               // CHMenu, CVMenu
               m_Color[2][15]=clrAliceBlue;     // Color of the background with selected items
               m_Color[2][16]=clrLightBlue;     // Color of the background without selected items
               m_Color[2][17]=clrRed;           // Tick color
               // CHProgress
               m_Color[2][18]=clrLightBlue;     // Background color   
               m_Color[2][19]=clrNavy;          // Border color
               m_Color[2][20]=clrDodgerBlue;    // Bar color
               m_Color[2][21]=clrNavy;          // Caption color
               // CDialer
               m_Color[2][22]=clrLightSteelBlue;// Background color
               m_Color[2][23]=clrNavy;          // Border color
               m_Color[2][24]=clrLightBlue;     // Number button color
               m_Color[2][25]=clrNavy;          // Caption color
               m_Color[2][26]=clrLightPink;     // Cancel button color
               m_Color[2][27]=clrLightGreen;    // OK button color
               m_Color[2][28]=clrPaleTurquoise; // Close button color
               m_Color[2][29]=clrAliceBlue;     // Text box background color
               m_Color[2][30]=clrNavy;          // Text color of the text box
               m_Color[2][31]=clrPink;          // Warning color                 
               // CForm
               m_Color[2][32]=C'221,239,244';   // Main color of the field for controls
               m_Color[2][33]=clrSteelBlue;     // Border color
               m_Color[2][34]=C'134,202,238';   // Button color
               m_Color[2][35]=clrNavy;          // Button caption color
               m_Color[2][36]=clrNavy;          // Top bar color
               m_Color[2][37]=clrNavy;          // Bottom bar color
               m_Color[2][38]=C'191,227,247';   // Top bar caption color 
               // CFrame
               m_Color[2][39]=C'221,239,244';   // Background
               m_Color[2][40]=clrNavy;          // Border
               m_Color[2][41]=clrNavy;          // Caption
               // CButtom
               m_Color[2][42]=clrLightSteelBlue;// Button color
               m_Color[2][43]=clrNavy;          // Button caption color    
               // CLabel
               m_Color[2][44]=clrNavy;          // Caption color                 
               // CCalendar    
               m_Color[2][45]=clrAliceBlue;     // Background color
               m_Color[2][46]=clrNavy;          // Frame color
               m_Color[2][47]=clrLightSteelBlue;// Buttons color
               m_Color[2][48]=clrNavy;          // Buttons labels color   
               m_Color[2][49]=clrNavy;          // Labels color
               m_Color[2][50]=C'100,230,230';
               m_Color[2][51]=C'245,255,255';   // Calendar days color
               m_Color[2][52]=C'200,230,230';   // Previous and next month days color
               m_Color[2][53]=clrPink;          // Selected day color  
               m_Color[2][54]=clrRed;           // Current day frame color
               
               // === green ===

               m_Color[3][0]=clrHoneydew;       // Text box background color
               m_Color[3][1]=clrDarkSlateGray;  // Text and border color of the text box
               m_Color[3][2]=clrDarkSlateGray;  // Caption color
               m_Color[3][3]=clrLightPink;      // Warning color          
               // CSpinInputBox (additional, the remaining are identical to the ones in CInputBox)
               m_Color[3][4]=clrDarkSeaGreen;   // Button color
               m_Color[3][5]=clrHoneydew;       // Flashing color
               // CVScrollBar, CHScrollBar (independent colors)
               m_Color[3][6]=clrDarkSlateGray;  // Border color
               m_Color[3][7]=C'162,199,158';    // Bar colors
               m_Color[3][8]=clrDarkSeaGreen;   // Button color
               m_Color[3][9]=clrLightPink;      // Warning color
               m_Color[3][10]=clrDarkSlateGray; // Caption (arrow) color
               m_Color[3][11]=C'206,225,204';   // Selected scroll box color
               m_Color[3][12]=C'188,216,186';   // Flashing button color
               m_Color[3][13]=C'188,216,186';   // Flashing scroll box color
               // CCheckBox, CRadioGroup use the colors of CInputBox (except for warning color which is absent in CCheckBox, CRadioGroup)
               // CList - background and text colors are taken from CInputBox, but the selection color is of its own
               m_Color[3][14]=clrPaleTurquoise; // Selected item color
               // CHMenu, CVMenu
               m_Color[3][15]=clrHoneydew;      // Color of the background with selected items
               m_Color[3][16]=C'201,222,199';   // Color of the background without selected items
               m_Color[3][17]=clrRed;           // Tick color
               // CHProgress
               m_Color[3][18]=C'201,222,199';   // Background color   
               m_Color[3][19]=clrDarkSlateGray; // Border color
               m_Color[3][20]=clrYellowGreen;   // Bar color
               m_Color[3][21]=clrDarkSlateGray; // Caption color
               // CDialer
               m_Color[3][22]=C'166,201,163';   // Background color
               m_Color[3][23]=clrDarkSlateGray; // Border color
               m_Color[3][24]=C'201,222,199';   // Number button color
               m_Color[3][25]=clrDarkSlateGray; // Caption color
               m_Color[3][26]=clrLightPink;     // Cancel button color
               m_Color[3][27]=clrLightGreen;    // OK button color
               m_Color[3][28]=clrPaleTurquoise; // Close button color
               m_Color[3][29]=clrHoneydew;      // Text box background color
               m_Color[3][30]=clrDarkSlateGray; // Text color of the text box
               m_Color[3][31]=clrPink;          // Warning color                     
               // CForm
               m_Color[3][32]=C'225,250,225';   // Main color of the field for controls
               m_Color[3][33]=C'70,117,117';    // Border color
               m_Color[3][34]=C'140,215,155';   // Button color
               m_Color[3][35]=clrDarkGreen;     // Button caption color
               m_Color[3][36]=clrDarkGreen;     // Top bar color
               m_Color[3][37]=clrDarkGreen;     // Bottom bar color
               m_Color[3][38]=C'180,255,180';   // Top bar caption color 
               // CFrame
               m_Color[3][39]=C'225,250,225';   // Background
               m_Color[3][40]=clrDarkSlateGray; // Border
               m_Color[3][41]=clrDarkSlateGray; // Caption
               // CButtom
               m_Color[3][42]=C'172,209,168';   // Button color
               m_Color[3][43]=C'36,62,62';      // Button caption color    
               // CLabel
               m_Color[3][44]=clrDarkSlateGray; // Caption color  
               // CCalendar    
               m_Color[3][45]=clrHoneydew;      // Background color
               m_Color[3][46]=clrDarkSlateGray; // Frame color
               m_Color[3][47]=clrDarkSeaGreen;  // Buttons color
               m_Color[3][48]=clrDarkSlateGray; // Buttons labels color   
               m_Color[3][49]=clrDimGray;       // Labels color
               m_Color[3][50]=clrSpringGreen;               
               m_Color[3][51]=C'240,255,240';   // Calendar days color
               m_Color[3][52]=C'200,240,200';   // Previous and next month days color
               m_Color[3][53]=clrPink;          // Selected day color  
               m_Color[3][54]=clrRed;           // Current day frame color
                              
               // ===yellow-black ===

               m_Color[4][0]=clrBlack;          // Text box background color
               m_Color[4][1]=clrYellow;         // Text and border color of the text box
               m_Color[4][2]=clrYellow;         // Caption color
               m_Color[4][3]=clrRed;            // Warning color          
               // CSpinInputBox (additional, the remaining are identical to the ones in CInputBox)
               m_Color[4][4]=clrBlack;          // Button color
               m_Color[4][5]=clrSilver;         // Flashing color
               // CVScrollBar, CHScrollBar (independent colors)
               m_Color[4][6]=clrYellow;         // Border color
               m_Color[4][7]=clrDimGray;        // Bar colors
               m_Color[4][8]=clrBlack;          // Button color
               m_Color[4][9]=clrRed;            // Warning color
               m_Color[4][10]=clrYellow;        // Caption (arrow) color
               m_Color[4][11]=clrDarkKhaki;     // Selected scroll box color
               m_Color[4][12]=clrGray;          // Flashing button color
               m_Color[4][13]=clrGray;          // Flashing scroll box color
               // CCheckBox, CRadioGroup use the colors of CInputBox (except for warning color which is absent in CCheckBox, CRadioGroup)
               // CList - background and text colors are taken from CInputBox, but the selection color is of its own
               m_Color[4][14]=clrNavy;          // Selected item color
               // CHMenu, CVMenu
               m_Color[4][15]=clrDimGray;       // Color of the background with selected items
               m_Color[4][16]=clrBlack;         // Color of the background without selected items
               m_Color[4][17]=clrYellow;        // Tick color
               // CHProgress
               m_Color[4][18]=clrDimGray;       // Background color   
               m_Color[4][19]=clrYellow;        // Border color
               m_Color[4][20]=clrChocolate;     // Bar color
               m_Color[4][21]=clrYellow;        // Caption color
               // CDialer
               m_Color[4][22]=clrDimGray;       // Background color
               m_Color[4][23]=clrYellow;        // Border color
               m_Color[4][24]=clrBlack;         // Number button color
               m_Color[4][25]=clrYellow;        // Caption color
               m_Color[4][26]=clrBrown;         // Cancel button color
               m_Color[4][27]=clrGreen;         // OK button color
               m_Color[4][28]=clrNavy;          // Close button color
               m_Color[4][29]=clrBlack;         // Text box background color
               m_Color[4][30]=clrYellow;        // Text color of the text box
               m_Color[4][31]=clrRed;           // Warning color                     
               // CForm
               m_Color[4][32]=C'45,45,0';       // Main color of the field for controls
               m_Color[4][33]=clrYellow;        // Border color
               m_Color[4][34]=clrKhaki;         // Button color
               m_Color[4][35]=C'45,45,0';       // Button caption color
               m_Color[4][36]=C'90,90,0';       // Top bar color
               m_Color[4][37]=C'90,90,0';       // Bottom bar color
               m_Color[4][38]=clrYellow;        // Top bar caption color                 
               // CFrame
               m_Color[4][39]=C'45,45,0';       // Background
               m_Color[4][40]=clrYellow;        // Border
               m_Color[4][41]=clrYellow;        // Caption
               // CButtom
               m_Color[4][42]=C'120,120,80';    // Button color
               m_Color[4][43]=clrYellow;        // Button caption color    
               // CLabel
               m_Color[4][44]=clrYellow;        // Caption color                 
               // CCalendar    
               m_Color[4][45]=clrBlack;         // Background color
               m_Color[4][46]=clrYellow;        // Frame color
               m_Color[4][47]=C'120,120,80';    // Buttons color
               m_Color[4][48]=clrYellow;        // Buttons labels color   
               m_Color[4][49]=clrYellow;        // Labels color
               m_Color[4][50]=clrDarkSlateGray;
               m_Color[4][51]=C'120,120,80';    // Calendar days color
               m_Color[4][52]=C'140,140,120';   // Previous and next month days color
               m_Color[4][53]=clrGreen;         // Selected day color  
               m_Color[4][54]=clrLime;          // Current day frame color
               
               // === green-black ===

               m_Color[5][0]=clrBlack;          // Text box background color
               m_Color[5][1]=clrLime;           // Text and border color of the text box
               m_Color[5][2]=clrLime;           // Caption color
               m_Color[5][3]=clrRed;            // Warning color          
               // CSpinInputBox (additional, the remaining are identical to the ones in CInputBox)
               m_Color[5][4]=clrBlack;          // Button color
               m_Color[5][5]=clrSilver;         // Flashing color
               // CVScrollBar, CHScrollBar (independent colors)
               m_Color[5][6]=clrLime;           // Border color
               m_Color[5][7]=clrDimGray;        // Bar colors
               m_Color[5][8]=clrBlack;          // Button color
               m_Color[5][9]=clrRed;            // Warning color
               m_Color[5][10]=clrLime;          // Caption (arrow) color
               m_Color[5][11]=clrGreen;         // Selected scroll box color
               m_Color[5][12]=clrGray;          // Flashing button color
               m_Color[5][13]=clrGray;          // Flashing scroll box color
               // CCheckBox, CRadioGroup use the colors of CInputBox (except for warning color which is absent in CCheckBox, CRadioGroup)
               // CList - background and text colors are taken from CInputBox, but the selection color is of its own
               m_Color[5][14]=clrNavy;          // Selected item color
               // CHMenu, CVMenu
               m_Color[5][15]=clrDimGray;       // Color of the background with selected items
               m_Color[5][16]=clrBlack;         // Color of the background without selected items
               m_Color[5][17]=clrLime;          // Tick color
               // CHProgress
               m_Color[5][18]=clrDimGray;       // Background color   
               m_Color[5][19]=clrLime;          // Border color
               m_Color[5][20]=clrForestGreen;   // Bar color
               m_Color[5][21]=clrLime;          // Caption color
               // CDialer
               m_Color[5][22]=clrDimGray;       // Background color
               m_Color[5][23]=clrLime;          // Border color
               m_Color[5][24]=clrBlack;         // Number button color
               m_Color[5][25]=clrLime;          // Caption color
               m_Color[5][26]=clrBrown;         // Cancel button color
               m_Color[5][27]=clrGreen;         // OK button color
               m_Color[5][28]=clrNavy;          // Close button color
               m_Color[5][29]=clrBlack;         // Text box background color
               m_Color[5][30]=clrLime;          // Text color of the text box
               m_Color[5][31]=clrRed;           // Warning color                     
               // CForm
               m_Color[5][32]=C'0,45,0';        // Main color of the field for controls
               m_Color[5][33]=clrLime;          // Border color
               m_Color[5][34]=clrPaleGreen;     // Button color
               m_Color[5][35]=C'0,45,0';        // Button caption color
               m_Color[5][36]=clrDarkSlateGray; // Top bar color
               m_Color[5][37]=clrDarkSlateGray; // Bottom bar color
               m_Color[5][38]=clrLime;          // Top bar caption color 
               // CFrame
               m_Color[5][39]=C'0,45,0';        // Background
               m_Color[5][40]=clrLime;          // Border
               m_Color[5][41]=clrLime;          // Caption
               // CButtom
               m_Color[5][42]=C'80,120,80';     // Button color
               m_Color[5][43]=clrLime;          // Button caption color    
               // CLabel
               m_Color[5][44]=clrLime;          // Caption color  
               // CCalendar    
               m_Color[5][45]=clrBlack;         // Background color
               m_Color[5][46]=clrLime;          // Frame color
               m_Color[5][47]=C'80,120,80';     // Buttons color
               m_Color[5][48]=clrLime;          // Buttons labels color   
               m_Color[5][49]=clrLime;          // Labels color
               m_Color[5][50]=C'120,120,80';
               m_Color[5][51]=C'80,120,80';     // Calendar days color
               m_Color[5][52]=C'120,140,120';   // Previous and next month days color
               m_Color[5][53]=C'50,100,255';    // Selected day color  
               m_Color[5][54]=clrYellow;        // Current day frame color
               
               // === turquoise-black ===

               m_Color[6][0]=clrBlack;          // Text box background color
               m_Color[6][1]=clrAqua;           // Text and border color of the text box
               m_Color[6][2]=clrAqua;           // Caption color
               m_Color[6][3]=clrRed;            // Warning color          
               // CSpinInputBox (additional, the remaining are identical to the ones in CInputBox)
               m_Color[6][4]=clrBlack;          // Button color
               m_Color[6][5]=clrSilver;         // Flashing color
               // CVScrollBar, CHScrollBar (independent colors)
               m_Color[6][6]=clrAqua;           // Border color
               m_Color[6][7]=clrDimGray;        // Bar colors
               m_Color[6][8]=clrBlack;          // Button color
               m_Color[6][9]=clrRed;            // Warning color
               m_Color[6][10]=clrAqua;          // Caption (arrow) color
               m_Color[6][11]=clrLightSeaGreen; // Selected scroll box color
               m_Color[6][12]=clrGray;          // Flashing button color
               m_Color[6][13]=clrGray;          // Flashing scroll box color
               // CCheckBox, CRadioGroup use the colors of CInputBox (except for warning color which is absent in CCheckBox, CRadioGroup)
               // CList - background and text colors are taken from CInputBox, but the selection color is of its own
               m_Color[6][14]=clrNavy;          // Selected item color
               // CHMenu, CVMenu
               m_Color[6][15]=clrDimGray;       // Color of the background with selected items
               m_Color[6][16]=clrBlack;         // Color of the background without selected items
               m_Color[6][17]=clrAqua;          // Tick color
               // CHProgress
               m_Color[6][18]=clrDimGray;       // Background color   
               m_Color[6][19]=clrAqua;          // Border color
               m_Color[6][20]=clrLightSeaGreen; // Bar color
               m_Color[6][21]=clrAqua;          // Caption color
               // CDialer
               m_Color[6][22]=clrDimGray;       // Background color
               m_Color[6][23]=clrAqua;          // Border color
               m_Color[6][24]=clrBlack;         // Number button color
               m_Color[6][25]=clrAqua;          // Caption color
               m_Color[6][26]=clrBrown;         // Cancel button color
               m_Color[6][27]=clrGreen;         // OK button color
               m_Color[6][28]=clrNavy;          // Close button color
               m_Color[6][29]=clrBlack;         // Text box background color
               m_Color[6][30]=clrAqua;          // Text color of the text box
               m_Color[6][31]=clrRed;           // Warning color                   
               // CForm
               m_Color[6][32]=C'0,45,45';       // Main color of the field for controls
               m_Color[6][33]=clrAqua;          // Border color
               m_Color[6][34]=clrMediumTurquoise;// Button color
               m_Color[6][35]=C'0,45,45';       // Button caption color
               m_Color[6][36]=clrSlateGray;     // Top bar color
               m_Color[6][37]=clrSlateGray;     // Bottom bar color
               m_Color[6][38]=clrAqua;          // Top bar caption color 
               // CFrame
               m_Color[6][39]=C'0,45,45';       // Background
               m_Color[6][40]=clrAqua;          // Border
               m_Color[6][41]=clrAqua;          // Caption
               // CButtom
               m_Color[6][42]=C'80,120,120';    // Button color
               m_Color[6][43]=clrAqua;          // Button caption color    
               // CLabel
               m_Color[6][44]=clrAqua;          // Caption color  
               // CCalendar    
               m_Color[6][45]=clrBlack;         // Background color
               m_Color[6][46]=clrAqua;          // Frame color
               m_Color[6][47]=C'80,120,120';    // Buttons color
               m_Color[6][48]=clrAqua;          // Buttons labels color   
               m_Color[6][49]=clrAqua;          // Labels color
               m_Color[6][50]=clrDarkSlateGray;
               m_Color[6][51]=C'80,120,120';    // Calendar days color
               m_Color[6][52]=C'120,140,140';   // Previous and next month days color
               m_Color[6][53]=clrBrown;         // Selected day color  
               m_Color[6][54]=clrYellow;        // Current day frame color
               
            return(m_Color[m_ShemeIndex][aColorIndex]); // Returning the value by the scheme number and color number in a scheme
         }
   		/*!	
   			Display of color swatches in the chart.
             \remark	   Schemes are arranged vertically from top to bottom, counting from zero. 
                        Colors are arranged from left to right, counting from zero.
   		*/           
         void Show(){ // Displaying all colors in all color schemes
            int m_sc=7; // Number of schemes
            int m_cc=45; // Number of colors in a scheme
            color m_bcolor=Color(1);
            int m_RemScheme=m_ShemeIndex;
               for(int s=0;s<m_sc;s++){
                  w.Label("ColorSchemes_"+IntegerToString(s),0,10,20+s*20,IntegerToString(s),m_bcolor);
               }
               for(int s=0;s<m_sc;s++){
                  m_ShemeIndex=s;
                     for(int c=0;c<m_cc;c++){
                        w.Canvas("ColorSchemes_"+IntegerToString(s)+"_"+IntegerToString(c),0,10+c*20+15,20+s*20,19,19,Color(c),m_bcolor);
                     }
               }
            ChartRedraw(0);
            m_ShemeIndex=m_RemScheme;
         }
   		/*!	
   			Deletion of color swatches displayed by the Show() method.
   		*/           
         void Hide(){ // Deletion of color swatches displayed by the Show() method
            int m_sc=7;
            int m_cc=45;         
               for(int s=0;s<m_sc;s++){
                  ObjectDelete(0,"ColorSchemes_"+IntegerToString(s));
                     for(int c=0;c<m_cc;c++){
                        ObjectDelete(0,"ColorSchemes_"+IntegerToString(s)+"_"+IntegerToString(c));
                     }
               }
            ChartRedraw(0);
         }
};

CColorSchemes ClrScheme;

//+------------------------------------------------------------------+
//|                                                                  |
//|         Control CLASSES                              |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|         CInputBox Class                                          |
//+------------------------------------------------------------------+

/*!
	\brief   Graphical control "Input Box".
	
	\details There are two operating modes: text data input, numeric data input. 
	         In the numeric data input mode, the value entered by a user can be limited by setting a value range, 
	         Both a point and a comma can be used as a decimal symbol.
	         When the program outputs the value, the input box is formatted according to the set 
	         number of decimal places. Work in subwindows is supported. 
   \remark	This control consists of two graphical objects: "Edit" (OBJ_EDIT) and "Label" (OBJ_LABEL).
            In order to get the "Edit" object name, "_E" is added to the aName parameter and "_L" is added for the "Label" object.
            
*/   

class CInputBox{
   private:
      string m_NameEdit;   // Name of the graphical object "Edit"
      string m_NameLabel;  // Name of the graphical object "Label"
      int m_Left;          // Х-coordinate
      int m_Top;           // Y-coordinate
      int m_Width;         // Width
      int m_Height;        // Height
      bool m_Visible;      // "Control is visible" flag
      int m_Digits;        // Number of decimal places for a double figure or -1 when working in the text mode
      string m_Caption;    // Caption
      string m_Value;      // Value
      double m_ValueMin;   // Minimum value
      double m_ValueMax;   // Maximum value
      color m_BgColor;     // Background color 
      color m_TxtColor;    // Text color
      color m_LblColor;    // Label color
      color m_WarningColor;// Warning background color
      bool m_Warning;      // Warning flag
      int m_SubWindow;     // Subwindow
      string m_Tag;        // Tag
      bool m_ReadOnly;     // Read only box
         void Create(){    // Graphical object creation function
            color m_ctmp=m_BgColor; // Normal background color
               if(m_Warning){ // Warning mode set
                  m_ctmp=m_WarningColor; // Text box will be filled with a warning color
               }
            w.Edit(m_NameEdit,m_SubWindow,m_Left,m_Top,m_Width,m_Height,m_Value,m_ctmp,m_TxtColor,7,"Arial"); // Text box creation
            g.SetReadOnly(m_NameEdit,m_ReadOnly);
               if(m_Caption!=""){ // Caption is present
                  w.Label(m_NameLabel,m_SubWindow,m_Left+m_Width+1,m_Top+2,m_Caption,m_LblColor,7,"Arial"); // Creating a label
               } 
         }   
         void Delete(){ // Graphical object deletion function
            ObjectDelete(0,m_NameEdit); // "Edit" object deletion
            ObjectDelete(0,m_NameLabel); // "Label" object deletion
         }    
   public:
		/*!	
			Control initialization.
            \param		string aName="CInputBox" - name,
            \param		int aWidth=50 - width,
            \param		int aDigits=-1 - number of decimal places (from zero onwards), -1 - work in the text mode,
            \param		string aCaption="CInputBox" - caption text (no caption if the value is "").
 		*/   
      void Init(string aName="CInputBox",int aWidth=50,int aDigits=-1,string aCaption="CInputBox"){ // Initialization method
         m_NameEdit=aName+"_E"; // Text box name preparation
         m_NameLabel=aName+"_L"; // Label name preparation
         m_Left=0; // X-coordinate
         m_Top=0; // Y-coordinate
         m_Width=aWidth; // Width
         m_Height=15; // Height
         m_Visible=false; // Visibility
         m_Digits=aDigits; // Operating mode and number of decimal places
         m_Caption=aCaption; // Caption text
         m_Value=""; // Text mode value
         if(aDigits>=0)m_Value=DoubleToString(0,m_Digits); // Numeric mode value
         m_ValueMin=-DBL_MAX; // Minimum value
         m_ValueMax=DBL_MAX; // Maximum value
         m_BgColor=ClrScheme.Color(0); // Input box background color
         m_TxtColor=ClrScheme.Color(1); // Text and border color of the text box
         m_LblColor=ClrScheme.Color(2); // Label color
         m_WarningColor=ClrScheme.Color(3); // Warning color
         m_Warning=false; // Mode: warning, normal
         m_SubWindow=0; // Subwindow number
         m_Tag=""; // Tag
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPos(int aLeft,int aTop){ // Setting the X- and Y-coordinates
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosLeft(int aLeft){ // Setting the X-coordinate 
         m_Left=aLeft;
      }   
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/             
      void SetPosTop(int aTop){ // Setting the Y-coordinate
         m_Top=aTop;
      }  
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/         
      void SetWidth(int aWidth){ // Setting the width 
         m_Width=aWidth;
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){ // Getting the X-coordinate
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/        
      int Top(){ // Getting the Y-coordinate
         return(m_Top);
      }
		/*!	
			Getting the width.
			\return  Value (int type).
			\remark  Text box value only without the caption width.
 		*/        
      int Width(){ // Getting the width
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/        
      int Height(){
         return(m_Height); // Getting the height
      }
		/*!	
			Enabling visibility.
 		*/       
      void Show(){ // Enabling the display at a preset position
         m_Visible=true; // Visibility registration 
         Create(); // Creation of graphical objects
         ChartRedraw(); // Chart update
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/        
      void Show(int aLeft,int aTop){ // Enabling the display at a set position
         SetPos(aLeft,aTop); // Registration of the coordinates
         Show(); // Enabling the display
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/   
      void Hide(){ // Hiding (deletion of graphical objects)
         m_Visible=false; // Registration of the visibility status
         Delete(); // Deletion of graphical objects
         ChartRedraw(); // Chart update
      }  
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/         
      void Refresh(){ // Updating display (deletion and creation)
         if(m_Visible){ // Visibility enabled
            Delete(); // Deletion of graphical objects
            Create(); // Creation of graphical objects
            ChartRedraw(); // Chart redrawing 
         }            
      }  
		/*!	
			Setting a string-type value.
			\param		string aValue - text.	
 		*/         
      void SetValue(string aValue){ // Setting the text value
         m_Value=aValue; // Assigning the value to a variable for storing the value
            if(m_Visible){ // Control visibility enabled
               g.Attach(m_NameEdit); // Attaching the text box to the object for graphical object management
               g.SetText(m_Value); // Setting the value in the text box
               ChartRedraw(); // Chart display update
            }
      }  
		/*!	
			Setting a double-type value.
			param		double aValue - value.	
 		*/         
      void SetValue(double aValue){ // Setting a numeric value
         if(m_Digits>=0){ // In the numeric mode
            aValue=NormalizeDouble(aValue,m_Digits); // Normalizing the value by the set decimal places
            aValue=MathMax(aValue,m_ValueMin); // "Adjusting" the value with the minimum acceptable value
            aValue=MathMin(aValue,m_ValueMax); // "Adjusting" the value with the maximum acceptable value
            SetValue(DoubleToString(aValue,m_Digits)); // Setting the received value as the text value
         }
         else{ // In the text mode
            SetValue((string)aValue); // Assigning the value to a variable for storing the value as it is
         }            
      }
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of a value modification by a user.
 		*/          
      int Event(const int id,const long & lparam,const double & dparam,const string & sparam){ // Event handling
         bool m_event=0; // Variable for an event belonging to this control
            if(id==CHARTEVENT_OBJECT_ENDEDIT){ // An event of a completed text box editing occurred
               if(sparam==m_NameEdit){ // Editing of the text box with the m_NameEdit name was carried out
                  if(m_Digits<0){ // In the text mode
                     g.Attach(m_NameEdit); // Attaching the text box for operation
                        if(g.Text()!=m_Value){ // The text box has a new value
                           m_Value=g.Text(); // Assigning the value to a variable for storing the value
                           m_event=1; // An event occurred
                        }
                  }
                  else{ // In the numeric mode
                     string m_OldValue=m_Value; // Variable with a preceding value of the control
                     g.Attach(m_NameEdit); // Attaching the text box for operation
                     string m_stmp=g.Text(); // Getting the text from the text box as entered by a user
                     StringReplace(m_stmp,",","."); // Replacing a comma with a point
                     double m_dtmp=StringToDouble(m_stmp); // Transformation into a number
                     SetValue(m_dtmp); // Setting the new numeric value
                        if(StringToDouble(m_Value)!=StringToDouble(m_OldValue)){ // Comparing the new value with a preceding value
                           m_event=1; // An event occurred 
                        }
                  }
               }
            }               
         return(m_event); // Returning the event. 0 - no event, 1 - there is an event
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/       
      void SetSubWindow(int aNumber){ // Defining the subwindow by the number
         int m_itmp=(int)MathMax(aNumber,0); // If the subwindow number is negative, 0 will be used - price chart
            if(m_itmp!=m_SubWindow){ // The specified number does not match the number where the control is located
               m_SubWindow=m_itmp; // New subwindow number registration
               Refresh(); // Recreating the graphical objects
            }
      }  
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/              
      void SetSubWindow(string aName){ // Defining the subwindow by the subwindow name
         SetSubWindow(ChartWindowFind(0,aName)); // Identifying the subwindow number by the name and defining the subwindow by the number
      }
		/*!	
			Getting the text value.
			\return Text.
 		*/       
      string ValueString(){ // Getting the text value
         return(m_Value);
      }
		/*!	
			Getting the numeric value.
			\return Value (double type).
 		*/         
      double ValueDouble(){ // Getting the numeric value
         return(StringToDouble(m_Value));
      }
		/*!	
			Enabling/disabling the warning color.
			\param bool aValue - true/false (warning/normal). 
 		*/        
      void SetWarning(bool aValue){ // Setting the warning mode
            if(m_Visible){ // Visibility enabled
               if(aValue){ // Enabling of the warning mode is required
                  if(!m_Warning){ // Warning mode has not been enabled
                     g.Attach(m_NameEdit); // Attaching the text box for operation 
                     g.SetBgColor(m_WarningColor); // Setting the warning background color of the text box
                  }
               }
               else{ // Warning mode should be disabled
                  if(m_Warning){ // Warning mode is enabled
                     g.Attach(m_NameEdit); // Attaching the text box for operation 
                     g.SetBgColor(m_BgColor); // Setting the normal background color                
                  }
               }
            }
         m_Warning=aValue; // Set mode registration
      }
		/*!	
			Getting the warning mode.
			\return bool type. True/false - warning/normal.
 		*/         
      bool Warning(){ // Getting the warning mode
         return(m_Warning);
      }
		/*!	
			Setting the maximum acceptable value.
			\param double aValue - maximum acceptable value. 
 		*/        
      void SetMaxValue(double aValue){ // Setting the maximum acceptable value
         m_ValueMax=aValue; // New maximum acceptable value registration
            if(m_Digits>=0){ // The control operates in the numeric mode
               if(StringToDouble(m_Value)>m_ValueMax){ // Current control value is higher than the new maximum acceptable value
                  SetValue(m_ValueMax); // Setting the new value equal to the maximum acceptable value
               }
            }         
      }
		/*!	
			Setting the minimum acceptable value.
			\param double aValue - minimum acceptable value. 
 		*/        
      void SetMinValue(double aValue){ // Setting the minimum acceptable value
         m_ValueMin=aValue; // New minimum acceptable value registration     
            if(m_Digits>=0){ // The control operates in the numeric mode
               if(StringToDouble(m_Value)<m_ValueMin){ // Current control value is lower than the new minimum acceptable value
                  SetValue(m_ValueMin); // Setting the new value equal to the minimum acceptable value 
               }
            }
      }
		/*!	
			Getting the maximum acceptable value.
			\return Value (double type).
 		*/         
      double MaxValue(){ // Getting the maximum acceptable value
         return(m_ValueMax); 
      }
		/*!	
			Getting the minimum acceptable value.
			\return Value (double type).
 		*/       
      double MinValue(){ // Getting the minimum acceptable value
         return(m_ValueMin);
      }
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/       
      void SetTag(string aValue){ // Setting a tag
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/        
      string Tag(){ // Getting a tag
         return(m_Tag);
      }  
		/*!	
			Setting the number of decimal places in the numeric mode.
			\param int aValue - number of decimal places.
 		*/          
      void SetDigits(int aValue){ // Setting the number of decimal places
         m_Digits=aValue; // New value registration
            if(m_Digits>=0){ // Numeric mode
               SetValue(ValueDouble()); // Resetting the current value
            }
      }  
		/*!	
			Getting the number of decimal places.
			\return int type. From zero onwards - number of decimal places. -1 - the control operates in the text mode.
 		*/       
      int Digits(){ // Getting the m_Digits value
         return(m_Digits);
      }   
		/*!	
			Control visibility.
			\return bool type. True/false - visible/hidden.
 		*/           
      bool Visible(){
         return(m_Visible);
      }
		/*!	
			Setting the "Read only" property.
			\param int aValue - true/false - read only/editing possible.
 		*/        
      void SetReadOnly(bool aValue){
         m_ReadOnly=aValue;
            if(m_Visible){
               g.SetReadOnly(m_NameEdit,m_ReadOnly);
            }
      }   
		/*!	
			Getting the "Read only" property.
			\return bool type. True/false - read only/editing possible.
 		*/        
      bool ReadOnly(){
         return(m_ReadOnly);
      }      
};

//+------------------------------------------------------------------+
//|        CSpinInputBox class                                      |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Spin Button Input Box".
   
   \details It is designed to input value by means of changing it by a set step
            utilizing "+" and "-" buttons. Keyboard value input is possible. A value 
            is formatted according to the number of digits defined
            by the changing step parameter. Work in subwindows is supported. 
   \remark	This control consists of CSpinInputBox control and 
            a label (OBJ_LABEL). In order to get the CSpinInputBox name, "_IB" is added to the aName parameter, 
            "_L" is added for the label, "_U" is added for "+" button
            and "_D" is added for "-" button.
*/  

class CSpinInputBox{
   protected:
      CInputBox m_ib;
      string m_NameSU;
      string m_NameSD;
      string m_NameLabel;
      int m_Left;
      int m_Top;
      int m_Width;
      int m_Height;
      string m_Caption;
      int m_SubWindow;
      color m_LblColor;
      color m_SpBgColor;
      color m_SpTxtColor;
      color m_FlashColor;
      color m_WrongColor;
      bool m_Visible;
      double m_Change;
      int m_Digits;
         int DefineDigits(double aValue){ // Function defining the number of decimal places by the double variable value
            int m_Digits=0;
               for(int i=8;i>=0;i--){
                  if(aValue>=NormalizeDouble(1.0/MathPow(10,i),8)){
                     m_Digits=i;
                  }
               }
            return(m_Digits);    
         }
         void Create(){
            w.Edit(m_NameSD,m_SubWindow,m_Left+m_Width-13,m_Top+7,13,8," -",m_SpBgColor,m_SpTxtColor,6,"Arial");
            w.Edit(m_NameSU,m_SubWindow,m_Left+m_Width-13,m_Top,13,8," +",m_SpBgColor,m_SpTxtColor,5,"Arial");
            g.SetReadOnly(m_NameSU,true);               
            g.SetReadOnly(m_NameSD,true);
               if(m_Caption!=""){ // Caption is present
                  w.Label(m_NameLabel,m_SubWindow,m_Left+m_Width+1,m_Top+2,m_Caption,m_LblColor,7,"Arial"); // Creating a label
               } 
         }
         void Delete(){
            ObjectDelete(0,m_NameSU); // Deletion of the up "button"
            ObjectDelete(0,m_NameSD); // Deletion of the dn "button"
            ObjectDelete(0,m_NameLabel); // "Label" object deletion         
         }
         void Flash(string aName,color aFlash,color aNormal){
            g.SetBgColor(aName,aFlash);
            g.Redraw();
            Sleep(100);
            g.SetBgColor(aName,aNormal);
            g.Redraw();      
         }         
   public:
		/*!	
			Control initialization.
            \param		string aName="CSpinInputBox" - name,
            \param		int aWidth=50 - width,
            \param		double aChange=0.1 - value changing step,
            \param		string aCaption="CSpinInputBox" - caption text (no caption if the value is "").
 		*/     
      void Init(string aName="CSpinInputBox",int aWidth=50,double aChange=0.1,string aCaption="CSpinInputBox"){
         m_NameSU=aName+"_U";
         m_NameSD=aName+"_D";
         m_NameLabel=aName+"_L";
         m_SubWindow=0;
         m_Left=0;
         m_Top=0; 
         m_Width=aWidth;
         m_Height=15;
         m_Caption=aCaption;         
         m_SpTxtColor=ClrScheme.Color(1); // Button caption color should match the text box border color
         m_LblColor=ClrScheme.Color(2);   // Caption color is identical to the text box caption color         
         m_WrongColor=ClrScheme.Color(3); // Warning color is similar to the text box color
         m_SpBgColor=ClrScheme.Color(4);  // Button color is being added
         m_FlashColor=ClrScheme.Color(5); // Flashing color is being added
         m_Visible=false;
         m_Change=aChange;
         m_Digits=DefineDigits(m_Change);
         m_ib.Init(aName+"_IB",m_Width-12,m_Digits,""); // Input box initialization
         m_ib.SetReadOnly(true);
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         m_ib.SetPos(m_Left,m_Top);
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
         m_ib.SetPosLeft(m_Left);
      } 
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/    
      void SetPosTop(int aTop){
         m_Top=aTop;
         m_ib.SetPosTop(m_Top);
      }  
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetWidth(int aWidth){
         m_Width=aWidth;
         m_ib.SetWidth(m_Width-12);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/  
      int Top(){
         return(m_Top);
      }
		/*!	
			Getting the width.
			\return  Value (int type).
			\remark  Text box value only without the caption width.
 		*/         
      int Width(){
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/ 
      int Height(){
         return(m_Height);
      }
		/*!	
			Enabling visibility.
 		*/        
      void Show(){
         m_Visible=true; 
         Create(); 
         m_ib.Show();
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/        
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/       
      void Hide(){
         m_Visible=false;
         Delete();
         m_ib.Hide();
      }   
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refresh(){
         if(m_Visible){
            Delete();
            Create(); 
            m_ib.Refresh();
         }            
      } 
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0, 1 or 2. 0 - no event. 1 – event of changing the value using the keyboard, 2 - using +/- buttons.
 		*/         
      int Event(const int id,const long & lparam,const double & dparam,const string & sparam){ // Event handling
         int m_event=m_ib.Event(id,lparam,dparam,sparam);
            if(m_event==0){
               double m_OldValue;
                  if(id==CHARTEVENT_OBJECT_CLICK){
                     if(sparam==m_NameSU){
                        m_OldValue=m_ib.ValueDouble();
                        m_ib.SetValue(m_OldValue+m_Change);
                           if(m_OldValue!=m_ib.ValueDouble()){
                              Flash(m_NameSU,m_FlashColor,m_SpBgColor);
                              m_event=2;
                           }
                           else{
                              Flash(m_NameSU,m_WrongColor,m_SpBgColor);
                           }
                     }
                     if(sparam==m_NameSD){
                        m_OldValue=m_ib.ValueDouble();
                        m_ib.SetValue(m_OldValue-m_Change);
                           if(m_OldValue!=m_ib.ValueDouble()){
                              Flash(m_NameSD,m_FlashColor,m_SpBgColor);
                              m_event=2;
                           }
                           else{
                              Flash(m_NameSD,m_WrongColor,m_SpBgColor);
                           }
                     }               
                  }
            }
         return(m_event);
      }   
		/*!	
			Setting the maximum acceptable value.
			\param double aValue - maximum acceptable value. 
 		*/         
      void SetMaxValue(double aValue){
         m_ib.SetMaxValue(aValue);
      }
		/*!	
			Setting the minimum acceptable value.
			\param double aValue - minimum acceptable value. 
 		*/        
      void SetMinValue(double aValue){
         m_ib.SetMinValue(aValue);
      }
		/*!	
			Getting the maximum acceptable value.
			\return Value (double type).
 		*/        
      double MaxValue(){
         return(m_ib.MaxValue()); 
      }
		/*!	
			Getting the minimum acceptable value.
			\return Value (double type).
 		*/         
      double MinValue(){
         return(m_ib.MinValue());
      }
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/       
      void SetTag(string aValue){
         m_ib.SetTag(aValue);
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/   
      string Tag(){
         return(m_ib.Tag());
      } 
		/*!	
			Setting the value.
			param		double aValue - value.	
 		*/          
      void SetValue(double aValue){
         m_ib.SetValue(aValue);
      }
		/*!	
			Getting the value.
			\return Double type.
 		*/         
      double Value(){
         return(m_ib.ValueDouble());
      }   
		/*!	
			Setting the changing step.
			param		double aValue - value.	
 		*/         
      void SetChange(double aValue){
         m_Change=aValue;
         m_Digits=DefineDigits(m_Change);
         m_ib.SetDigits(m_Digits);
      }  
		/*!	
			Getting the changing step.
			\return Double type.
 		*/       
      double Change(){
         return(m_Change);
      }  
		/*!	
			Getting the number of decimal places.
			\return int type.
			\remark Defined by the step value.
 		*/        
      int Digits(){
         return(m_Digits);
      }
		/*!	
			Enabling/disabling the warning color.
			\param bool aValue - true/false (warning/normal). 
 		*/        
      void SetWarning(bool aValue){
         m_ib.SetWarning(aValue);
      }
		/*!	
			Getting the warning mode.
			\return bool type. True/false - warning/normal.
 		*/         
      bool Warning(){
         return(m_ib.Warning());
      }
		/*!	
			Setting the "Read only" property.
			\param int aValue - true/false - read only/editing possible.
 		*/        
      void SetReadOnly(bool aValue){
         m_ib.SetReadOnly(aValue);
      }
		/*!	
			Getting the "Read only" property.
			\return bool type. True/false - read only/editing possible.
 		*/        
      bool ReadOnly(){
         return(m_ib.ReadOnly());
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/          
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               m_ib.SetSubWindow(m_SubWindow);
               Refresh();
            }
      }    
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/             
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }  
};

//+------------------------------------------------------------------+
//|         CCheckBox Class                                          |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Checkbox".
   \details Work in subwindows is supported. 
   \remark	It consists of a rectangle label OBJ_RECTANGLE_LABEL and two labels 
            OBJ_LABEL: for a tick and a caption.
            In order to get a rectangle label name, "_B" is added to the aName parameter, 
            "_C" is added for a tick, "_L" is added for a caption.
            and "_D" is added for "-" button.
*/  

class CCheckBox{
   protected:
      color m_BgColor;
      color m_CheckColor;
      color m_LabelColor;
      string m_Caption;
      string m_NameBox;
      string m_NameChecked;
      string m_NameLabel;
      int m_Left;
      int m_Top;
      int m_Width;
      int m_Height;
      bool m_Value;
      bool m_Visible;
      int m_SubWindow;
      string m_Tag;
         void Create(){
            w.Canvas(m_NameBox,m_SubWindow,m_Left,m_Top,m_Width,m_Height,m_BgColor,m_CheckColor);
            string m_str=" ";
               if(m_Value){
                  m_str=CharToString(252);
               }
            w.Label(m_NameChecked,m_SubWindow,m_Left+1,m_Top+1,m_str,m_CheckColor,12,"Wingdings");
            w.Label(m_NameLabel,m_SubWindow,m_Left+m_Width+1,m_Top+2,m_Caption,m_LabelColor,7);            
         }
         void Delete(){
            ObjectDelete(0,m_NameBox);
            ObjectDelete(0,m_NameChecked);
            ObjectDelete(0,m_NameLabel);
         }
   public:
		/*!	
			Control initialization.
         \param		string aName="CCheckBox" - name,
         \param		string aCaption="CCheckBox" - caption text (no caption if the value is "").
 		*/   
      void Init(string aName="CCheckBox",string aCaption="CCheckBox"){
         m_NameBox=aName+"_B";
         m_NameChecked=aName+"_C";
         m_NameLabel=aName+"_L";
         m_Caption=aCaption;
         m_BgColor=ClrScheme.Color(0);
         m_CheckColor=ClrScheme.Color(1);
         m_LabelColor=ClrScheme.Color(2);
         m_Value=false;
         m_Visible=false;
         m_Width=15;
         m_Height=15;
         m_SubWindow=0;
         m_Tag="";
      }
		/*!	
			Enabling visibility.
 		*/       
      void Show(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         Show();
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/      
      void Show(){
         m_Visible=true;
         Create();
         ChartRedraw(0);
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/       
      void Hide(){
         m_Visible=false;
         Delete();
         ChartRedraw(0);
      } 
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refresh(){
         if(m_Visible){
            Delete();
            Create();
            ChartRedraw(0);
         }            
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }   
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/          
      void SetPosTop(int aTop){
         m_Top=aTop;
      }  
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/        
      int Left(){
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/         
      int Top(){
         return(m_Top);
      }
		/*!	
			Getting the width.
			\return  Value (int type).
			\remark  Caption width is not taken into account.
 		*/        
      int Width(){
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/       
      int Height(){
         return(m_Height);
      }
		/*!	
			Setting the value.
			\param		bool aValue - true/false.	
 		*/         
      void SetValue(bool aValue){
         m_Value=aValue;
            if(m_Visible){
               string m_str=" ";
                  if(m_Value){
                     m_str=CharToString(252);
                  }
               g.SetText(m_NameChecked,m_str);
               g.Redraw();
            }
      }
		/*!	
			Getting the value.
			\return bool type.
 		*/        
      bool Value(){
         return(m_Value);
      }  
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of a value modification by a user.
 		*/          
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_event=0;
            if(id==CHARTEVENT_OBJECT_CLICK){
               if(sparam==m_NameBox || sparam==m_NameChecked || sparam==m_NameLabel){
                     if(m_Value){
                        SetValue(false);
                     }
                     else{
                        SetValue(true);
                     }
                  m_event=1;
               }
            }
         return(m_event);
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/         
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      }   
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/              
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }  
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/       
      void SetTag(string aValue){ // Setting a tag
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/        
      string Tag(){ // Getting a tag
         return(m_Tag);
      }               
};

//+------------------------------------------------------------------+
//|         CRadioGroup Class                                        |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Radio Buttons".
   \details A group of associated radio buttons. The coordinates of every 
            radio button are specified separately relative to the anchor
            point of the whole group. Work in subwindows is supported. 
   \remark	A radio button consists of three labels (OBJ_LABEL), one
            for the background, one for the outline or outline with a dot, and one
            for a caption. In order to get caption names,  "_B", "_D", "_L" are added 
            to the aName parameter.
*/

class CRadioGroup{
   protected:
      struct sRBut{
         string NameRound;
         string NameDot;
         string NameLabel;
         string Caption;
         int Left;
         int Top;
      };
      sRBut m_Button[];
      int m_Left;
      int m_Top;
      int m_Value;
      bool m_Visible;
      color m_RoundColor;
      color m_DotColor;
      color m_LabelColor;      
      string m_Name;
      int m_SubWindow;
      int m_Width;
      int m_Height;
      string m_Tag;
         void Create(){
            for(int i=0;i<ArraySize(m_Button);i++){
               w.Label(m_Button[i].NameRound,m_SubWindow,m_Left+m_Button[i].Left,m_Top+m_Button[i].Top,CharToString(108),m_RoundColor,12,"Wingdings");
               w.Label(m_Button[i].NameDot,m_SubWindow,m_Left+m_Button[i].Left,m_Top+m_Button[i].Top,CharToString(161),m_DotColor,12,"Wingdings");               
                  if(m_Button[i].Caption!=""){
                     w.Label(m_Button[i].NameLabel,m_SubWindow,m_Left+m_Button[i].Left+13,m_Top+m_Button[i].Top+3,m_Button[i].Caption,m_LabelColor,7,"Arial");
                  }  
                  if(m_Value>-1){
                     g.SetText(m_Button[m_Value].NameDot,CharToString(164));
                  }
            }
         }
         void Delete(){
            for(int i=0;i<ArraySize(m_Button);i++){
               ObjectDelete(0,m_Button[i].NameRound);
               ObjectDelete(0,m_Button[i].NameDot);
               ObjectDelete(0,m_Button[i].NameLabel);
            }
         }
   public:
		/*!	
			Control initialization.
            \param		string aName="CRadioGroup" - name.
 		*/      
      void Init(string aName="CRadioGroup"){
         m_RoundColor=ClrScheme.Color(0);
         m_DotColor=ClrScheme.Color(1);
         m_LabelColor=ClrScheme.Color(2);
         m_Name=aName;
         ArrayResize(m_Button,0);
         m_Value=-1;
         m_Visible=false;
         m_SubWindow=0;
         m_Left=0;
         m_Top=0;
         m_Width=0;
         m_Height=0;         
         string m_Tag="";
      }
		/*!	
			Adding a radio button.
            \param		string aCaption="Radio" - caption next to the button,
            \param		int aLeft - X-coordinate (distance from the left side of the group),
            \param		int aTop - Y-coordinate (distance from the top side of the group).
 		*/         
      void AddButton(string aCaption="Radio",int aLeft=0,int aTop=0){
         int m_LastIndex=ArraySize(m_Button);
         ArrayResize(m_Button,m_LastIndex+1);
         m_Button[m_LastIndex].NameRound=m_Name+"_B("+IntegerToString(m_LastIndex)+")";
         m_Button[m_LastIndex].NameDot=m_Name+"_D("+IntegerToString(m_LastIndex)+")";
         m_Button[m_LastIndex].NameLabel=m_Name+"_L("+IntegerToString(m_LastIndex)+")";
         m_Button[m_LastIndex].Caption=aCaption;
         m_Button[m_LastIndex].Left=aLeft;
         m_Button[m_LastIndex].Top=aTop;
         m_Width=MathMax(m_Width,aLeft+14);
         m_Height=MathMax(m_Height,aTop+14);         
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/        
      void Show(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         Show();
      }
		/*!	
			Enabling visibility.
 		*/         
      void Show(){
         m_Visible=true;
         Create();
         ChartRedraw(0);
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/       
      void Hide(){
         m_Visible=false;
         Delete();
         ChartRedraw(0);
      } 
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refresh(){
         if(m_Visible){
            Delete();
            Create();
            ChartRedraw(0);
         }            
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/    
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      
      }  
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/           
      void SetPosTop(int aTop){
         m_Top=aTop;
      }  
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/ 
      int Left(){
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/   
      int Top(){
         return(m_Top);
      }
		/*!	
			Getting the width.
			\return  Value (int type).
			\remark  Caption width is not taken into account.
 		*/  
      int Width(){
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/  
      int Height(){
         return(m_Height);
      }
		/*!	
			Setting the value (of an activated radio button).
			\param		string aValue - radio button index.	
 		*/         
      void SetValue(int aValue){
            if(m_Value>-1 && m_Visible){
               g.SetText(m_Button[m_Value].NameDot,CharToString(161));
               g.Redraw();
            }
         m_Value=aValue;
         m_Value=MathMin(m_Value,ArraySize(m_Button)-1);
            if(m_Value>-1 && m_Visible){
               g.SetText(m_Button[m_Value].NameDot,CharToString(164));
               g.Redraw();
            }    
                 
      }      
		/*!	
			Getting the value (of the activated radio button index).
			\return int type.
 		*/ 
      int Value(){
         return(m_Value);
      }
		/*!
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of a value modification by a user.
 		*/         
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_event=0;
            if(id==CHARTEVENT_OBJECT_CLICK){
               if(StringFind(sparam,m_Name,0)==0){
                  int m_pos1=StringFind(sparam,"(",0);
                  int m_pos2=StringFind(sparam,")",0);
                  int m_Index=(int)StringToInteger(StringSubstr(sparam,m_pos1+1,m_pos2-m_pos1-1));
                     if(m_Index!=m_Value){
                        SetValue(m_Index);
                        m_event=1;
                     }
               }
            }    
         return(m_event);
      }    
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/           
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      }   
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/              
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }  
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/        
      void SetTag(string aValue){ // Setting a tag
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/        
      string Tag(){ // Getting a tag
         return(m_Tag);
      }                   
};

//+------------------------------------------------------------------+
//|         CVScrollBar Class                                         |
//+------------------------------------------------------------------+

/*!
   \brief  Graphical control "Vertical Scrollbar".
   \details Work in subwindows is supported. 
   \remark	One control consists of five graphical objects: 
            "Edit", scroll up button, scroll down button, scroll box,
            upper part of the bar (between the scroll up button and the scroll box),
            lower part of the bar (between the scroll down button and the scroll box).
            In order to get the names, "_UB" and "_LB" (for buttons) 
            are added to aName, "_UF" and "_LF" are added for bars, "_S" is added for the scroll box.
*/

class CVScrollBar{
   protected:
      string m_NameUpperButton;
      string m_NameLowerButton;
      string m_NameUpperField;
      string m_NameLowerField;
      string m_NameSlider;
      int m_Left;
      int m_Top;      
      int m_Height;
      int m_Width;  
      int m_Min;
      int m_Max;
      int m_SmallChange;
      int m_LageChange;
      int m_Value;
      bool m_SliderSelected;
      int m_SliderHeight;
      int m_Range;
      int m_A;
      int m_D;
      int m_L;
      int m_G;
      int m_T;
      int m_E;
      int m_K;
      int m_N;
      color m_BorderColor;
      color m_BarColor;
      color m_ButtonColor;
      color m_WarningColor; 
      color m_TxtColor;
      color m_SliderSelectedColor;
      color m_ButtonFlashColor;
      color m_BarFlashColor;
      int m_FontSize;
      bool m_Visible;
      int m_SubWindow;
      string m_Tag;
         void SetWidthAndFontSize(int aValue){
            // 13 18 19 24 30
            // 6  7  8  10 14                   
            switch(aValue){
               case 1:
                  m_Width=13;
                  m_FontSize=6;               
               break;
               case 2:
                  m_Width=19;
                  m_FontSize=8;                
               break;
               case 3:
                  m_Width=24;
                  m_FontSize=10;   
               break;                
               case 4:
                  m_Width=30;
                  m_FontSize=14;                  
               break;
            }   
         }               
         void SolveMainPositions(){
               if(m_Max<m_Min){
                  int m_tmp=m_Max;
                  m_Max=m_Min;
                  m_Min=m_tmp;
               }
            if(m_Max==m_Min)m_Max=m_Min+1;
            m_Range=m_Max-m_Min;   
            m_LageChange=MathMin(m_LageChange,m_Range);
            m_SmallChange=MathMin(m_SmallChange,m_LageChange);
            m_LageChange=(int)MathMax(m_LageChange,1);
            m_SmallChange=(int)MathMax(m_SmallChange,1);            
            m_D=m_Height-2*m_Width;
            m_SliderHeight=m_D/(m_Range/m_LageChange+1); 
            m_SliderHeight=(int)MathMax(m_SliderHeight,3);
            m_L=m_D-m_SliderHeight;
            m_G=m_Top-m_Width+m_Height; 
            m_E=m_Top+m_Width;  
            m_T=m_E+m_SliderHeight;  
            m_K=m_D-m_SliderHeight;
            m_N=m_Top+m_Width+m_SliderHeight/2;
         }
         void SetObjectsPos(){  
            m_Value=MathMin(MathMax(m_Value,m_Min),m_Max); 
            m_A=m_K*(m_Value-m_Min)/m_Range;
            g.Attach(m_NameUpperField);   g.SetXYDistance(m_Left,m_E-1);      g.SetXYSize(m_Width,m_A+2);
            g.Attach(m_NameLowerField);   g.SetXYDistance(m_Left,m_T+m_A-1);  g.SetXYSize(m_Width,m_L-m_A+2);  
            g.Attach(m_NameSlider);       g.SetXYDistance(m_Left,m_E+m_A-1);  g.SetXYSize(m_Width,m_SliderHeight+2); 
            g.Attach(m_NameSlider);       g.SetBgColor(m_ButtonColor);        
            g.Attach(m_NameLowerButton);  g.SetXYDistance(m_Left,m_Top);      g.SetXYSize(m_Width,m_Width);
            g.Attach(m_NameUpperButton);  g.SetXYDistance(m_Left,m_G);        g.SetXYSize(m_Width,m_Width); 
            ChartRedraw(0);
         } 
         void Create(){
            m_Value=MathMin(MathMax(m_Value,m_Min),m_Max); 
            m_A=m_K*(m_Value-m_Min)/m_Range;
            w.Edit(m_NameUpperField,m_SubWindow,m_Left,m_E-1,m_Width,m_A+2,"",m_BarColor,m_BorderColor);
            g.SetReadOnly(m_NameUpperField,true);
            w.Edit(m_NameLowerField,m_SubWindow,m_Left,m_T+m_A-1,m_Width,m_L-m_A+2,"",m_BarColor,m_BorderColor);
            g.SetReadOnly(m_NameLowerField,true);
            w.Edit(m_NameSlider,m_SubWindow,m_Left,m_E+m_A-1,m_Width,m_SliderHeight+2,"",m_ButtonColor,m_BorderColor);
            g.SetReadOnly(m_NameSlider,true);
            w.Edit(m_NameLowerButton,m_SubWindow,m_Left,m_Top,m_Width,m_Width," /\\",m_ButtonColor,m_BorderColor,m_FontSize,"Arial");
            g.SetReadOnly(m_NameLowerButton,true);
            w.Edit(m_NameUpperButton,m_SubWindow,m_Left,m_G,m_Width,m_Width," \\/",m_ButtonColor,m_BorderColor,m_FontSize,"Arial");
            g.SetReadOnly(m_NameUpperButton,true);            
         }  
         void Delete(){
            ObjectDelete(0,m_NameUpperButton);
            ObjectDelete(0,m_NameLowerButton);
            ObjectDelete(0,m_NameUpperField);
            ObjectDelete(0,m_NameLowerField);
            ObjectDelete(0,m_NameSlider);
         }   
         void ChartClickY(double aDparam,int & aY){
            long hs=0;
            long ps=0;
               for(int i=0;i<ChartGetInteger(0,CHART_WINDOWS_TOTAL);i++){
                  hs+=3+ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,i);
                     if(hs>=aDparam){
                        aY=(int)(aDparam-ps-3); 
                        break;
                     }
                  ps=hs;
               } 
         }  
         void RePose(){
            if(m_Visible){
               SolveMainPositions(); 
               SetObjectsPos();
               ChartRedraw();
            }
         }  
         void Flash(string aName,color aFlash,color aNormal){
            g.SetBgColor(aName,aFlash);
            g.Redraw();
            Sleep(100);
            g.SetBgColor(aName,aNormal);
            g.Redraw();      
         }                           
   public: 
		/*!	
			Control initialization.
            \param		string aName="CVScrollBar" - name,
            \param		int aHeight=100 - height,
            \param		int aSizeType=1 - size (four sizes 1-4).
 		*/      
      void Init(string aName="CVScrollBar",int aHeight=100,int aSizeType=1){
         m_Visible=false;         
         m_NameUpperButton=aName+"_UB";
         m_NameLowerButton=aName+"_LB";
         m_NameUpperField=aName+"_UF";
         m_NameLowerField=aName+"_LF";
         m_NameSlider=aName+"_S";        
         //=============================
         m_BorderColor=ClrScheme.Color(6);
         m_BarColor=ClrScheme.Color(7);
         m_ButtonColor=ClrScheme.Color(8);
         m_WarningColor=ClrScheme.Color(9); 
         m_TxtColor=ClrScheme.Color(10);
         m_SliderSelectedColor=ClrScheme.Color(11);
         m_ButtonFlashColor=ClrScheme.Color(12);
         m_BarFlashColor=ClrScheme.Color(13);
         //=============================
         m_Min=0;
         m_Max=100;
         m_SmallChange=1;
         m_LageChange=10;
         m_Value=0;
         m_Height=aHeight;         
         m_SubWindow=0;
         SetWidthAndFontSize(aSizeType);
         string m_Tag="";
      }
		/*!	
			Enabling visibility.
 		*/         
      void Show(){
         m_Visible=true;
         SolveMainPositions();
         Create();
         ChartRedraw();
      }  
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/               
      void Show(int aLeft,int aTop){ 
         m_Left=aLeft;
         m_Top=aTop;
         Show();
      } 
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/         
      void Hide(){
         m_Visible=false;
         Delete();
         ChartRedraw();
      } 
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/               
      void Refresh(){
         if(m_Visible){
            Delete();
            SolveMainPositions();
            Create();
            ChartRedraw();
         }
      }
		/*!	
			Control visibility.
			\return bool type. True/false - visible/hidden.
 		*/  
      bool Visible(){
         return(m_Visible);
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }   
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/   		             
      void SetPosTop(int aTop){
         m_Top=aTop;
      } 
		/*!	
			Setting the size.
            \param		int aValue - size from 1 to 4.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/ 
      void SetSizeType(int aValue){
         SetWidthAndFontSize(aValue);
      }  
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/             
      int Left(){
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/    
      int Top(){
         return(m_Top);
      }
		/*!	
			Setting the height.
            \param		int aWidth - height.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetHeight(int aValue){
         m_Height=aValue;
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/         
      int Height(){
         return(m_Height);
      }   
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/   
      int Width(){
         return(m_Width);
      }
		/*!	
			Setting the minimum value.
			\param double aValue - value. 
 		*/        
      void SetMin(int aValue){
         m_Min=aValue;
      }
		/*!	
			Setting the maximum value.
			\param double aValue - value. 
 		*/        
      void SetMax(int aValue){
         m_Max=aValue;
      }
		/*!	
			Setting a minor change (when clicking the buttons).
			\param double aValue - value. 
 		*/         
      void SetSmallChange(int aValue){
         m_SmallChange=aValue;
      }
		/*!	
			Setting a major change (when clicking the bar).
			\param double aValue - value. 
 		*/      
      void SetLageChange(int aValue){
         m_LageChange=aValue;
      }      
		/*!	
			Setting the value (of the scroll box position).
			\param double aValue - value. 
 		*/        
      void SetValue(int aValue){
         m_Value=aValue;
         RePose();
      }  
		/*!	
			Getting the minimum value.
			\return Value (int type).
 		*/         
      int Min(){
         return(m_Min);
      }
		/*!	
			Getting the maximum value.
			\return Value (int type).
 		*/        
      int Max(){
         return(m_Max);
      }
		/*!	
			Getting the minor change.
			\return Value (int type).
 		*/       
      int SmallChange(){
         return(m_SmallChange);
      }
		/*!	
			Getting the major change.
			\return Value (int type).
 		*/        
      int LageChange(){
         return(m_LageChange);
      }  
		/*!	
			Getting the value (of the scroll box position).
			\return Value (int type).
 		*/           
      int Value(){
         return(m_Value);
      }  
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of a value modification by a user.
 		*/             
      int Event(const int id,const long & lparam,const double & dparam,const string & sparam){
         int m_old=m_Value;
            if(id==CHARTEVENT_OBJECT_CLICK){
               int m_Y;
               ChartClickY(dparam,m_Y);
                  if(sparam==m_NameLowerButton){
                        if(m_Value>m_Min){
                           Flash(m_NameLowerButton,m_ButtonFlashColor,m_ButtonColor);
                        }
                        else{
                           Flash(m_NameLowerButton,m_WarningColor,m_ButtonColor);
                        }                           
                        if(m_SliderSelected){
                           m_Value=m_Min;
                           m_SliderSelected=false;
                        }
                        else{   
                           m_Value-=m_SmallChange;
                           m_Value=MathMax(m_Value,m_Min);
                        }
                     RePose(); 
                  }
                  if(sparam==m_NameUpperButton){
                        if(m_Value<m_Max){
                           Flash(m_NameUpperButton,m_ButtonFlashColor,m_ButtonColor);
                        }
                        else{
                           Flash(m_NameUpperButton,m_WarningColor,m_ButtonColor);
                        }                    
                        if(m_SliderSelected){
                           m_Value=m_Max;
                           m_SliderSelected=false;
                        }
                        else{              
                           m_Value+=m_SmallChange;
                           m_Value=MathMin(m_Value,m_Max);
                        }                  
                     RePose();
                  }         
                  if(sparam==m_NameUpperField){
                     Flash(m_NameUpperField,m_BarFlashColor,m_BarColor);           
                        if(m_SliderSelected){
                           m_Value=m_Min+m_Range*(m_Y-m_N)/m_L;
                           m_Value=MathMin(MathMax(m_Value,m_Min),m_Max);
                           m_SliderSelected=false;
                        }
                        else{
                           m_Value-=m_LageChange;
                           m_Value=MathMin(MathMax(m_Value,m_Min),m_Max);
                        }                  
                     RePose();  
                  }
                  if(sparam==m_NameLowerField){
                     Flash(m_NameLowerField,m_BarFlashColor,m_BarColor);               
                        if(m_SliderSelected){
                           m_Value=m_Min+m_Range*(m_Y-m_N)/m_L;
                           m_Value=MathMin(MathMax(m_Value,m_Min),m_Max);
                           m_SliderSelected=false;
                        }
                        else{
                           m_Value+=m_LageChange;
                           m_Value=MathMin(MathMax(m_Value,m_Min),m_Max);
                        }                  
                     RePose();      
                  } 
                  if(sparam==m_NameSlider){                  
                     if(m_SliderSelected){   
                        g.Attach(m_NameSlider);       
                        m_SliderSelected=false;
                        g.SetBgColor(m_ButtonColor);
                        g.Redraw();
                     }
                     else{
                        m_SliderSelected=true;
                        g.Attach(m_NameSlider);
                        g.SetBgColor(m_SliderSelectedColor);
                        g.Redraw();
                     }
                  }       
            }
            if(m_old!=m_Value){
               return(1);
            }
         return(0);
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/        
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      }  
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/               
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }  
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/        
      void SetTag(string aValue){ // Setting a tag
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/         
      string Tag(){ // Getting a tag
         return(m_Tag);
      }         
};

//+------------------------------------------------------------------+
//|         CHScrollBar Class                                         |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Horizontal Scrollbar".
   \details Work in subwindows is supported. 
   \remark	One control consists of five graphical objects: 
            "Edit", left scroll button, right scroll button, scroll box,
            left part of the bar (between the left scroll button and the scroll box),
            right part of the bar (between the scroll box and the right scroll button).
            In order to get the names, "_UB" and "_LB" (for buttons) 
            are added to aName, "_UF" and "_LF" are added for bars, "_S" is added for the scroll box.
*/

class CHScrollBar{
   protected:
      string m_NameUpperButton;
      string m_NameLowerButton;
      string m_NameUpperField;
      string m_NameLowerField;
      string m_NameSlider;
      int m_Left;
      int m_Top;      
      int m_Height;
      int m_Width;  
      int m_Min;
      int m_Max;
      int m_SmallChange;
      int m_LageChange;
      int m_Value;
      bool m_SliderSelected;
      int m_SliderWidth;
      int m_Range;
      int m_A;
      int m_D;
      int m_L;
      int m_G;
      int m_T;
      int m_E;
      int m_K;
      int m_N;
      color m_BorderColor;
      color m_BarColor;
      color m_ButtonColor;
      color m_WarningColor; 
      color m_TxtColor;
      color m_SliderSelectedColor;
      color m_ButtonFlashColor;
      color m_BarFlashColor;
      int m_FontSize;
      bool m_Visible;
      int m_SubWindow;
      string m_Tag;
         void SetWidthAndFontSize(int aValue){
            switch(aValue){
               case 1:
                  m_Height=13;
                  m_FontSize=8;               
               break;
               case 2:
                  m_Height=19;
                  m_FontSize=11;                
               break;
               case 3:
                  m_Height=24;
                  m_FontSize=15;   
               break;                
               case 4:
                  m_Height=30;
                  m_FontSize=19;                  
               break;
            }   
         }               
         void SolveMainPositions(){
               if(m_Max<m_Min){
                  int m_tmp=m_Max;
                  m_Max=m_Min;
                  m_Min=m_tmp;
               }
            if(m_Max==m_Min)m_Max=m_Min+1;
            m_Range=m_Max-m_Min;   
            m_LageChange=MathMin(m_LageChange,m_Range);
            m_SmallChange=MathMin(m_SmallChange,m_LageChange);
            m_LageChange=(int)MathMax(m_LageChange,1);
            m_SmallChange=(int)MathMax(m_SmallChange,1);            
            m_D=m_Width-2*m_Height;
            m_SliderWidth=m_D/(m_Range/m_LageChange+1); 
            m_SliderWidth=(int)MathMax(m_SliderWidth,3);
            m_L=m_D-m_SliderWidth;
            m_G=m_Left-m_Height+m_Width; 
            m_E=m_Left+m_Height;  
            m_T=m_E+m_SliderWidth;  
            m_K=m_D-m_SliderWidth;
            m_N=m_Left+m_Height+m_SliderWidth/2;
         }
         void SetObjectsPos(){  
            m_Value=MathMin(MathMax(m_Value,m_Min),m_Max); 
            m_A=m_K*(m_Value-m_Min)/m_Range;
            g.Attach(m_NameUpperField);   g.SetXYDistance(m_E-1,m_Top);      g.SetXYSize(m_A+2,m_Height);
            g.Attach(m_NameLowerField);   g.SetXYDistance(m_T+m_A-1,m_Top);  g.SetXYSize(m_L-m_A+2,m_Height);  
            g.Attach(m_NameSlider);       g.SetXYDistance(m_E+m_A-1,m_Top);  g.SetXYSize(m_SliderWidth+2,m_Height); 
            g.Attach(m_NameSlider);       g.SetBgColor(m_ButtonColor);        
            g.Attach(m_NameLowerButton);  g.SetXYDistance(m_Left,m_Top);     g.SetXYSize(m_Height,m_Height);
            g.Attach(m_NameUpperButton);  g.SetXYDistance(m_G,m_Top);        g.SetXYSize(m_Height,m_Height); 
            ChartRedraw(0);
         } 
         void Create(){
            m_Value=MathMin(MathMax(m_Value,m_Min),m_Max); 
            m_A=m_K*(m_Value-m_Min)/m_Range;
            w.Edit(m_NameUpperField,m_SubWindow,m_E-1,m_Top,m_A+2,m_Height,"",m_BarColor,m_BorderColor);
            g.SetReadOnly(m_NameUpperField,true);
            w.Edit(m_NameLowerField,m_SubWindow,m_T+m_A-1,m_Top,m_L-m_A+2,m_Height,"",m_BarColor,m_BorderColor);
            g.SetReadOnly(m_NameLowerField,true);
            w.Edit(m_NameSlider,m_SubWindow,m_E+m_A-1,m_Top,m_SliderWidth+2,m_Height,"",m_ButtonColor,m_BorderColor);
            g.SetReadOnly(m_NameSlider,true);
            w.Edit(m_NameLowerButton,m_SubWindow,m_Left,m_Top,m_Height,m_Height,"<",m_ButtonColor,m_BorderColor,m_FontSize,"Arial");
            g.SetReadOnly(m_NameLowerButton,true);
            w.Edit(m_NameUpperButton,m_SubWindow,m_G,m_Top,m_Height,m_Height,">",m_ButtonColor,m_BorderColor,m_FontSize,"Arial");
            g.SetReadOnly(m_NameUpperButton,true);            
         }  
         void Delete(){
            ObjectDelete(0,m_NameUpperButton);
            ObjectDelete(0,m_NameLowerButton);
            ObjectDelete(0,m_NameUpperField);
            ObjectDelete(0,m_NameLowerField);
            ObjectDelete(0,m_NameSlider);
         }   
         void RePose(){
            if(m_Visible){
               SolveMainPositions(); 
               SetObjectsPos();
               ChartRedraw();
            }
         }  
         void Flash(string aName,color aFlash,color aNormal){
            g.SetBgColor(aName,aFlash);
            g.Redraw();
            Sleep(100);
            g.SetBgColor(aName,aNormal);
            g.Redraw();      
         }                           
   public: 
		/*!	
			Control initialization.
            \param		string aName="CHScrollBar" - name,
            \param		int aHeight=100 - height,
            \param		int aSizeType=1 - size (four sizes 1-4).
 		*/
      void Init(string aName="CHScrollBar",int aWidth=100,int aSizeType=1){
         m_Visible=false;         
         m_NameUpperButton=aName+"_UB";
         m_NameLowerButton=aName+"_LB";
         m_NameUpperField=aName+"_UF";
         m_NameLowerField=aName+"_LF";
         m_NameSlider=aName+"_S";        
         //=============================
         m_BorderColor=ClrScheme.Color(6);
         m_BarColor=ClrScheme.Color(7);
         m_ButtonColor=ClrScheme.Color(8);
         m_WarningColor=ClrScheme.Color(9); 
         m_TxtColor=ClrScheme.Color(10);
         m_SliderSelectedColor=ClrScheme.Color(11);
         m_ButtonFlashColor=ClrScheme.Color(12);
         m_BarFlashColor=ClrScheme.Color(13);
         //=============================
         m_Min=0;
         m_Max=100;
         m_SmallChange=1;
         m_LageChange=10;
         m_Value=0;
         m_Width=aWidth;         
         m_SubWindow=0;
         SetWidthAndFontSize(aSizeType);
         m_Tag="";
      }
		/*!	
			Enabling visibility.
 		*/        
      void Show(){
         m_Visible=true;
         SolveMainPositions();
         Create();
         ChartRedraw();
      } 
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/               
      void Show(int aLeft,int aTop){ 
         m_Left=aLeft;
         m_Top=aTop;
         Show();
      }   
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/         
      void Hide(){
         m_Visible=false;
         Delete();
         ChartRedraw();
      }     
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/          
      void Refresh(){
         if(m_Visible){
            Delete();
            SolveMainPositions();
            Create();
            ChartRedraw();
         }
      }
		/*!	
			Control visibility.
			\return bool type. True/false - visible/hidden.
 		*/ 
      bool Visible(){
         return(m_Visible);
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }    
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetPosTop(int aTop){
         m_Top=aTop;
      } 
		/*!	
			Setting the size.
            \param		int aValue - size from 1 to 4.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/ 
      void SetSizeType(int aValue){
         SetWidthAndFontSize(aValue);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/         
      int Left(){
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/  
      int Top(){
         return(m_Top);
      }
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetWidth(int aValue){
         m_Width=aValue;
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/  
      int Height(){
         return(m_Height);
      }   
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/       
      int Width(){
         return(m_Width);
      }
		/*!	
			Setting the minimum value.
			\param double aValue - value. 
 		*/  
      void SetMin(int aValue){
         m_Min=aValue;
      }
		/*!	
			Setting the maximum value.
			\param double aValue - value. 
 		*/         
      void SetMax(int aValue){
         m_Max=aValue;
      }
		/*!	
			Setting a minor change (when clicking the buttons).
			\param double aValue - value. 
 		*/         
      void SetSmallChange(int aValue){
         m_SmallChange=aValue;
      }
		/*!	
			Setting a major change (when clicking the bar).
			\param double aValue - value. 
 		*/         
      void SetLageChange(int aValue){
         m_LageChange=aValue;
      }     
		/*!	
			Setting the value (of the scroll box position).
			\param double aValue - value. 
 		*/  
      void SetValue(int aValue){
         m_Value=aValue;
         RePose();
      }  
		/*!	
			Getting the minimum value.
			\return Value (int type).
 		*/          
      int Min(){
         return(m_Min);
      }
		/*!	
			Getting the maximum value.
			\return Value (int type).
 		*/        
      int Max(){
         return(m_Max);
      }
		/*!	
			Getting the minor change.
			\return Value (int type).
 		*/  
      int SmallChange(){
         return(m_SmallChange);
      }
		/*!	
			Getting the major change.
			\return Value (int type).
 		*/        
      int LageChange(){
         return(m_LageChange);
      }   
		/*!	
			Getting the value (of the scroll box position).
			\return Value (int type).
 		*/      
      int Value(){
         return(m_Value);
      }  
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of a value modification by a user.
 		*/              
      int Event(const int id,const long & lparam,const double & dparam,const string & sparam){
         int m_old=m_Value;
            if(id==CHARTEVENT_OBJECT_CLICK){
               int m_Y=(int)lparam-2;
                  if(sparam==m_NameLowerButton){
                        if(m_Value>m_Min){
                           Flash(m_NameLowerButton,m_ButtonFlashColor,m_ButtonColor);
                        }
                        else{
                           Flash(m_NameLowerButton,m_WarningColor,m_ButtonColor);
                        }                           
                        if(m_SliderSelected){
                           m_Value=m_Min;
                           m_SliderSelected=false;
                        }
                        else{   
                           m_Value-=m_SmallChange;
                           m_Value=MathMax(m_Value,m_Min);
                        }
                     RePose(); 
                  }
                  if(sparam==m_NameUpperButton){
                        if(m_Value<m_Max){
                           Flash(m_NameUpperButton,m_ButtonFlashColor,m_ButtonColor);
                        }
                        else{
                           Flash(m_NameUpperButton,m_WarningColor,m_ButtonColor);
                        }                    
                        if(m_SliderSelected){
                           m_Value=m_Max;
                           m_SliderSelected=false;
                        }
                        else{              
                           m_Value+=m_SmallChange;
                           m_Value=MathMin(m_Value,m_Max);
                        }                  
                     RePose();
                  }         
                  if(sparam==m_NameUpperField){
                     Flash(m_NameUpperField,m_BarFlashColor,m_BarColor);           
                        if(m_SliderSelected){
                           m_Value=m_Min+m_Range*(m_Y-m_N)/m_L;
                           m_Value=MathMin(MathMax(m_Value,m_Min),m_Max);
                           m_SliderSelected=false;
                        }
                        else{
                           m_Value-=m_LageChange;
                           m_Value=MathMin(MathMax(m_Value,m_Min),m_Max);
                        }                  
                     RePose();  
                  }
                  if(sparam==m_NameLowerField){
                     Flash(m_NameLowerField,m_BarFlashColor,m_BarColor);               
                        if(m_SliderSelected){
                           m_Value=m_Min+m_Range*(m_Y-m_N)/m_L;
                           m_Value=MathMin(MathMax(m_Value,m_Min),m_Max);
                           m_SliderSelected=false;
                        }
                        else{
                           m_Value+=m_LageChange;
                           m_Value=MathMin(MathMax(m_Value,m_Min),m_Max);
                        }                  
                     RePose();      
                  } 
                  if(sparam==m_NameSlider){                  
                     if(m_SliderSelected){   
                        g.Attach(m_NameSlider);       
                        m_SliderSelected=false;
                        g.SetBgColor(m_ButtonColor);
                        g.Redraw();
                     }
                     else{
                        m_SliderSelected=true;
                        g.Attach(m_NameSlider);
                        g.SetBgColor(m_SliderSelectedColor);
                        g.Redraw();
                     }
                  }       
            }
            if(m_old!=m_Value){
               return(1);
            }
         return(0);
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/        
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      }        
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/          
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }  
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/           
      void SetTag(string aValue){ // Setting a tag
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/        
      string Tag(){ // Getting a tag
         return(m_Tag);
      }         
};

//+------------------------------------------------------------------+
//|         CList Class                                              |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "List".
   \details Work in subwindows is supported. 
   \remark	One control consists of several text boxes (OBJ_EDIT)
            and a vertical scrollbar. In order to get the scrollbar name,
            "_SB" is added to aName and "_IT" is added for the text box names specifying
            the text box index in parenthesis.
*/

class CList{
   protected:
      string m_Name;   
      int m_Left;
      int m_Top;
      int m_Width;
      int m_HeightInItems;      
      int m_Height;
      string m_ItemText[];
      int m_SubWindow;
      CVScrollBar m_sb;
      bool m_Visible;
      int m_Selected;
      color m_BgColor;
      color m_TxtColor;
      color m_SelColor;        
      int m_LastSelected;
      bool m_SbVisible;
      int m_FieldsCount;
      bool m_AllowDeselect;
      void Create(){
         int m_w=m_Width;
            if(ArraySize(m_ItemText)>m_HeightInItems){ // Scrollbar required
               m_SbVisible=true; // Scrollbar visibility
               m_w-=m_sb.Width(); // Width of text boxes
               m_sb.SetPos(m_Left+m_w,m_Top); // Setting the scrollbar position
               m_sb.SetHeight(m_Height);
               m_sb.SetMax(ArraySize(m_ItemText)-m_HeightInItems); // Setting the maximum scrollbar value
               m_sb.SetLageChange(m_HeightInItems); // Setting the major scrollbar change
               m_sb.SetSubWindow(m_SubWindow);
                  if(m_sb.Value()>ArraySize(m_ItemText)-m_HeightInItems){ // Current scrollbar value adjustment
                     m_sb.SetValue(ArraySize(m_ItemText)-m_HeightInItems); 
                  }
               m_w++; // Hide the right sides of the text box frames under the scrollbar
            }
            else{ // Without the scrollbar
               m_SbVisible=false; // Scrollbar not visible
               m_sb.SetValue(0); // Setting the scrollbar value
            }
         int s=m_sb.Value(); // Display values starting from the scrollbar value
         int e=MathMin(s+m_HeightInItems,ArraySize(m_ItemText)); // Value display limit
         int i=0; // Text box index
         string m_ItemName;
            for(;s<e;s++,i++){ // Boxes with values
               m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
               w.Edit(m_ItemName,m_SubWindow,m_Left,m_Top+i*14,m_w,15,m_ItemText[s],m_BgColor,m_TxtColor);
               g.SetReadOnly(m_ItemName,true);
            }  
            for(;i<m_HeightInItems;i++){ // Empty boxes
               m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
               w.Edit(m_ItemName,m_SubWindow,m_Left,m_Top+i*14,m_w,15,"",m_BgColor,m_TxtColor);
               g.SetReadOnly(m_ItemName,true);
            }
         m_FieldsCount=m_HeightInItems;
         SelectedON(); // Change color of the selected item
      }
      void SelectedON(){
         if(m_Selected>=0){ // Selected item present
            m_LastSelected=-1; // Still unknown if the selected item is visible
            int m_Index=m_Selected-m_sb.Value(); // Index of the text box with the selected item
               if(m_Index>=0 && m_Index<m_HeightInItems){ // Selected item visible
                  m_LastSelected=m_Index; // Save to disable later
                  g.SetBgColor(m_Name+"_IT("+IntegerToString(m_Index)+")",m_SelColor); // Setting the color of the selected item
               }
         }      
      }
      void SelectedOFF(){
         if(m_LastSelected>=0){ // Selected text box present
            g.SetBgColor(m_Name+"_IT("+IntegerToString(m_LastSelected)+")",m_BgColor); // Change the color to the normal one
            m_LastSelected=-1; // Mark that no selected box is present
         }
      }
      void Delete(){
         for(int i=0;i<m_FieldsCount;i++){
            string m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
            ObjectDelete(0,m_ItemName);
         }  
      }
      void PutValues(){
         int s=m_sb.Value(); // Display values starting from the scrollbar value
         int e=MathMin(s+m_HeightInItems,ArraySize(m_ItemText)); // Value display limit
         int i=0; // Text box index
         string m_ItemName;
            for(;s<e;s++,i++){ // Boxes with values
               m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
               g.SetText(m_ItemName,m_ItemText[s]);
            }  
            for(;i<m_HeightInItems;i++){ // Empty boxes
               m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
               g.SetText(m_ItemName," ");
            }      
      }
   public:
		/*!	
			Control initialization.
            \param		string aName="CList" - name,
            \param		int aWidth=100 - width,
            \param		int aHeightInItems=8 - height in lines.
 		*/      
      void Init(string aName="CList",int aWidth=100,int aHeightInItems=8){
         m_Visible=false;
         m_Name=aName; 
         m_Width=aWidth;
         m_HeightInItems=aHeightInItems;         
         m_Left=0;
         m_Top=0;
         ArrayResize(m_ItemText,0);
         //==========================
         m_BgColor=ClrScheme.Color(0);
         m_TxtColor=ClrScheme.Color(1);
         m_SelColor=ClrScheme.Color(14);   
         //==========================      
         m_Height=m_HeightInItems*14+1;
         m_sb.Init(aName+"_SB",m_Height,1);
         m_sb.SetMin(0);
         m_sb.SetValue(0);
         m_sb.SetSmallChange(1);
         m_sb.SetLageChange(aHeightInItems);
         m_Selected=-1;
         m_LastSelected=-1;
         m_SbVisible=false;
         m_AllowDeselect=true;
      }
		/*!	
			Setting the permission to deselect an item.
            \param		bool aValue - true/false - allowed/not allowed.
 		*/       
      void SetAllowDeselect(bool aValue){
         m_AllowDeselect=aValue;
      }
		/*!	
			Getting the permission to deselect an item.
			\return bool type. True/false - allowed/not allowed.
 		*/    		      
      bool AllowDeselect(){
         return(m_AllowDeselect);
      }  
		/*!	
			Adding an item to the list.
         \param		string aText - text.			
			\remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/   
      void AddItem(string aText){
         ArrayResize(m_ItemText,ArraySize(m_ItemText)+1);
         m_ItemText[ArraySize(m_ItemText)-1]=aText;
      }
		/*!	
			Deleting an item from the list.
         \param		int aIndex - index of the item to be deleted.			
			\remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void DeleteItem(int aIndex){
         if(aIndex<ArraySize(m_ItemText)){
               for(int i=aIndex;i<ArraySize(m_ItemText)-1;i++){
                  m_ItemText[i]=m_ItemText[i+1];
               }
            ArrayResize(m_ItemText,ArraySize(m_ItemText)-1);
               if(aIndex<m_Selected){
                  m_Selected--;
               }
               else if(aIndex==m_Selected){
                  m_Selected=-1;               
               }
         }            
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/ 
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }   
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/           
      void SetPosTop(int aTop){
         m_Top=aTop;
      }
		/*!	
			Enabling visibility.
 		*/         
      void Show(){
         m_Visible=true;
         Create();
            if(m_SbVisible){
               m_sb.Show();
            }
            else{
               ChartRedraw(0);
            }               
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/  
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/       
      void Hide(){
         m_Visible=false;
         Delete();
            if(m_SbVisible){
               m_sb.Hide();
               m_SbVisible=false;
            }
            else{
               ChartRedraw(0);
            }               
      }
		/*!	
			Control visibility.
			\return bool type. True/false - visible/hidden.
 		*/       
      bool Visible(){
         return(m_Visible);
      }    
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/          
      void Refresh(){
         if(m_Visible){      
            Hide();
            Show();
            ChartRedraw(0);
         }            
      }
		/*!	
			Number of list items.
			\return Number of elements (int type).
 		*/        
      int Count(){
         return(ArraySize(m_ItemText));
      }
		/*!	
			Selected item index.
			\return Selected item index (int type), if no selected items present, return -1.
 		*/         
      int SelectedIndex(){
         return(m_Selected);
      }
		/*!	
			Selected item text.
			\return Selected item text (string type), if no selected items present, return "".
 		*/       
      string SelectedText(){
         if(m_Selected<0)return("");
         return(m_ItemText[m_Selected]);
      }
		/*!	
			Getting the item text by its index.
         \param		int aIndex - item index.					
			\return Item text (string type).
 		*/       
      string Text(int aIndex){
         return(m_ItemText[aIndex]);
      }
		/*!	
			Item selection.
         \param		int aIndex - item index.					
 		*/        
      void SetSelectedIndex(int aIndex){
         if(aIndex>=-1 && aIndex<ArraySize(m_ItemText)){
            m_Selected=aIndex;
               if(m_Visible){
                  SelectedOFF();
                  SelectedON();
                  ChartRedraw();
               }
         }            
      }
		/*!	
			Setting the item text by its index.
         \param		int aIndex - item index,
         \param		int aText - item text,
 		*/        
      void SetText(int aIndex,string aText){
         m_ItemText[aIndex]=aText;
            if(m_Visible){
               if(aIndex>=m_sb.Value() && aIndex<m_sb.Value()+m_HeightInItems){
                  g.SetText(m_Name+"_IT("+IntegerToString(aIndex-m_sb.Value())+")",aText);
                  ChartRedraw();
               }
            }
      }
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetWidth(int aValue){
         m_Width=aValue;
      }
		/*!	
			Setting the height in items.
            \param		int aValue - height in items.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetHeightInItems(int aValue){
         m_HeightInItems=aValue;
         m_Height=m_HeightInItems*14+1;
      }
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/  
      int Width(){
         return(m_Width);
      }  
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/   
      int Height(){
         return(m_Height);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/      
      int Left(){
         return(m_Left);      
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/  
      int Top(){
         return(m_Top);        
      }
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of a value modification by a user.
 		*/        
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_event=0;
            if(m_sb.Event(id,lparam,dparam,sparam)==1){
               SelectedOFF();
               PutValues();
               SelectedON();
               ChartRedraw();
            }
            if(id==CHARTEVENT_OBJECT_CLICK){
               if(StringFind(sparam,m_Name+"_IT(",0)==0){
                  int m_Pos1=StringFind(sparam,"_IT(",0);
                  int m_Pos2=StringFind(sparam,")",m_Pos1);
                  int m_Index=m_sb.Value()+(int)StringToInteger(StringSubstr(sparam,m_Pos1+4,m_Pos2-m_Pos1-4));
                     if(m_Index<ArraySize(m_ItemText)){
                        if(m_Index==m_Selected){
                           if(m_AllowDeselect){
                              SetSelectedIndex(-1);
                              m_event=1;
                           }
                        }
                        else{
                           SetSelectedIndex(m_Index);
                           m_event=2;
                        }
                     }
               }
            }
         return(m_event);
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/ 
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      }   
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/          
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }    
		/*!	
			Scrolling the list to the specified item.
			\param int aValue - item index.
 		*/          
      void ScrollTo(int aValue){
         if(ArraySize(m_ItemText)>m_HeightInItems){
            aValue=(int)MathMin(ArraySize(m_ItemText)-m_HeightInItems,(int)MathMax(0,aValue));
            m_sb.SetValue(aValue);
               if(m_Visible){
                  SelectedOFF();
                  PutValues();
                  SelectedON();
                  ChartRedraw();
               }               
         }
      }
		/*!	
			Getting the index of the first visible item.
			\return Item index (int type).
 		*/         
      int FirstIndex(){
         return(m_sb.Value());
      }
		/*!	
			Clearing the list.
         \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/     
      void Clear(){
         ArrayResize(m_ItemText,0);
         m_Selected=-1;
         m_LastSelected=-1;         
      }
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/         
      void SetTag(string aValue){ // Setting a tag
         m_sb.SetTag(aValue);
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/         
      string Tag(){ // Getting a tag
         return(m_sb.Tag());
      }         
};

//+------------------------------------------------------------------+
//|         CListMS Class                                            |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Multiple-Selection List".
   \details Selection of multiple list items is allowed. Work in subwindows is supported. 
   \remark	One control consists of several text boxes (OBJ_EDIT)
            and a vertical scrollbar. In order to get the scrollbar name,
            "_SB" is added to aName and "_IT" is added for the text box names specifying
            the text box index in parenthesis.
*/

class CListMS{
   protected:
      string m_Name;   
      int m_Left;
      int m_Top;
      int m_Width;
      int m_HeightInItems;      
      int m_Height;
      string m_ItemText[];
      bool m_Itemselected[];
      int m_SubWindow;
      CVScrollBar m_sb;
      bool m_Visible;
      color m_BgColor;
      color m_TxtColor;
      color m_SelColor;        
      bool m_SbVisible;
      int m_FieldsCount;
      int m_LastChanged;
      int m_SearchFrom;
      void Create(){
         int m_w=m_Width;
            if(ArraySize(m_ItemText)>m_HeightInItems){ // Scrollbar required
               m_SbVisible=true; // Scrollbar visibility
               m_w-=m_sb.Width(); // Width of text boxes
               m_sb.SetPos(m_Left+m_w,m_Top); // Setting the scrollbar position
               m_sb.SetHeight(m_Height);
               m_sb.SetMax(ArraySize(m_ItemText)-m_HeightInItems); // Setting the maximum scrollbar value
               m_sb.SetLageChange(m_HeightInItems); // Setting the major scrollbar change
               m_sb.SetSubWindow(m_SubWindow);
                  if(m_sb.Value()>ArraySize(m_ItemText)-m_HeightInItems){ // Current scrollbar value adjustment
                     m_sb.SetValue(ArraySize(m_ItemText)-m_HeightInItems); 
                  }
               m_w++; // Hide the right sides of the text box frames under the scrollbar
            }
            else{ // Without the scrollbar
               m_SbVisible=false; // Scrollbar not visible
               m_sb.SetValue(0); // Setting the scrollbar value
            }
         int s=m_sb.Value(); // Display values starting from the scrollbar value
         int e=MathMin(s+m_HeightInItems,ArraySize(m_ItemText)); // Value display limit
         int i=0; // Text box index
         string m_ItemName;
            for(;s<e;s++,i++){ // Boxes with values
               m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
               color m_Clr=m_BgColor;
               if(m_Itemselected[s])m_Clr=m_SelColor;
               w.Edit(m_ItemName,m_SubWindow,m_Left,m_Top+i*14,m_w,15,m_ItemText[s],m_Clr,m_TxtColor);
               g.SetReadOnly(m_ItemName,true);
            }  
            for(;i<m_HeightInItems;i++){ // Empty boxes
               m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
               w.Edit(m_ItemName,m_SubWindow,m_Left,m_Top+i*14,m_w,15,"",m_BgColor,m_TxtColor);
               g.SetReadOnly(m_ItemName,true);
            }
         m_FieldsCount=m_HeightInItems;
      }

      void Delete(){
         for(int i=0;i<m_FieldsCount;i++){
            string m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
            ObjectDelete(0,m_ItemName);
         }  
      }
      void PutValues(){
         int s=m_sb.Value(); // Display values starting from the scrollbar value
         int e=MathMin(s+m_HeightInItems,ArraySize(m_ItemText)); // Value display limit
         int i=0; // Text box index
         string m_ItemName;
            for(;s<e;s++,i++){ // Boxes with values
               m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
               g.SetText(m_ItemName,m_ItemText[s]);
               color m_Clr=m_BgColor;
               if(m_Itemselected[s])m_Clr=m_SelColor;   
               g.SetBgColor(m_ItemName,m_Clr);
            }  
            for(;i<m_HeightInItems;i++){ // Empty boxes
               m_ItemName=m_Name+"_IT("+IntegerToString(i)+")";
               g.SetText(m_ItemName," ");
            }      
      }
   public:
		/*!	
			Control initialization.
            \param		string aName="CListMS" - name,
            \param		int aWidth=100 - width,
            \param		int aHeightInItems=8 - height in lines.
 		*/        
      void Init(string aName="CListMS",int aWidth=100,int aHeightInItems=8){
         m_Visible=false;
         m_Name=aName; 
         m_Width=aWidth;
         m_HeightInItems=aHeightInItems;         
         m_Left=0;
         m_Top=0;
         ArrayResize(m_ItemText,0);
         ArrayResize(m_Itemselected,0);
         //==========================
         m_BgColor=ClrScheme.Color(0);
         m_TxtColor=ClrScheme.Color(1);
         m_SelColor=ClrScheme.Color(14);   
         //==========================      
         m_Height=m_HeightInItems*14+1;
         m_sb.Init(aName+"_SB",m_Height,1);
         m_sb.SetMin(0);
         m_sb.SetValue(0);
         m_sb.SetSmallChange(1);
         m_sb.SetLageChange(aHeightInItems);
         m_SbVisible=false;
         m_LastChanged=-1;
         m_SearchFrom=0;
      }
		/*!	
			Adding an item to the list.
         \param		string aText - text.			
			\remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void AddItem(string aText){
         ArrayResize(m_ItemText,ArraySize(m_ItemText)+1);
         m_ItemText[ArraySize(m_ItemText)-1]=aText;
         ArrayResize(m_Itemselected,ArraySize(m_Itemselected)+1);
         m_Itemselected[ArraySize(m_Itemselected)-1]=false;         
      }
		/*!	
			Deleting an item from the list.
         \param		int aIndex - index of the item to be deleted.			
			\remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void DeleteItem(int aIndex){
         if(aIndex<ArraySize(m_ItemText)){
               for(int i=aIndex;i<ArraySize(m_ItemText)-1;i++){
                  m_ItemText[i]=m_ItemText[i+1];
                  m_Itemselected[i]=m_Itemselected[i+1];
               }
            ArrayResize(m_ItemText,ArraySize(m_ItemText)-1);
            ArrayResize(m_Itemselected,ArraySize(m_Itemselected)-1);
         }            
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }   
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/            
      void SetPosTop(int aTop){
         m_Top=aTop;
      }
		/*!	
			Enabling visibility.
 		*/        
      void Show(){
         m_Visible=true;
         Create();
            if(m_SbVisible){
               m_sb.Show();
            }
            else{
               ChartRedraw(0);
            }               
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/        
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/       
      void Hide(){
         m_Visible=false;
         Delete();
            if(m_SbVisible){
               m_sb.Hide();
               m_SbVisible=false;
            }
            else{
               ChartRedraw(0);
            }               
      }
		/*!	
			Control visibility.
			\return bool type. True/false - visible/hidden.
 		*/        
      bool Visible(){
         return(m_Visible);
      }  
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/            
      void Refresh(){
         if(m_Visible){      
            Hide();
            Show();
            ChartRedraw(0);
         }            
      }
		/*!	
			Number of list items.
			\return Number of elements (int type).
 		*/        
      int Count(){
         return(ArraySize(m_ItemText));
      }
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetWidth(int aValue){
         m_Width=aValue;
      }
		/*!	
			Setting the height in items.
            \param		int aValue - height in items.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetHeightInItems(int aValue){
         m_HeightInItems=aValue;
         m_Height=m_HeightInItems*14+1;
      }
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/  
      int Width(){
         return(m_Width);
      }   
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/ 
      int Height(){
         return(m_Height);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/ 
      int Left(){
         return(m_Left);      
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/ 
      int Top(){
         return(m_Top);        
      }
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of a value modification by a user.
 		*/   
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_event=0;
            if(m_sb.Event(id,lparam,dparam,sparam)==1){
               PutValues();
               ChartRedraw();
            }
            if(id==CHARTEVENT_OBJECT_CLICK){
               if(StringFind(sparam,m_Name+"_IT(",0)==0){
                  int m_Pos1=StringFind(sparam,"_IT(",0);
                  int m_Pos2=StringFind(sparam,")",m_Pos1);
                  int m_Index=m_sb.Value()+(int)StringToInteger(StringSubstr(sparam,m_Pos1+4,m_Pos2-m_Pos1-4));
                  SetSelected(m_Index,!Selected(m_Index));
                     if(Selected(m_Index)){
                        m_event=2;
                     }
                     else{
                        m_event=1;                     
                     }
               }
            }
         return(m_event);
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/       
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      }   
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/             
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }    
		/*!	
			Scrolling the list to the specified item.
			\param int aValue - item index.
 		*/         
      void ScrollTo(int aValue){
         if(ArraySize(m_ItemText)>m_HeightInItems){
            aValue=(int)MathMin(ArraySize(m_ItemText)-m_HeightInItems,(int)MathMax(0,aValue));
            m_sb.SetValue(aValue);
               if(m_Visible){
                  PutValues();
                  ChartRedraw();
               }               
         }
      }
		/*!	
			Getting the index of the first visible item.
			\return Item index (int type).
 		*/       
      int FirstIndex(){
         return(m_sb.Value());
      }
		/*!	
			Clearing the list.
         \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void Clear(){
         ArrayResize(m_ItemText,0);
         ArrayResize(m_Itemselected,0);
      }
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/         
      void SetTag(string aValue){ // Setting a tag
         m_sb.SetTag(aValue);
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/   
      string Tag(){ // Getting a tag
         return(m_sb.Tag());
      }   
		/*!	
			Setting the item text by its index.
         \param		int aIndex - item index,
         \param		int aText - item text,
 		*/                
      void SetText(int aIndex,string aText){
         m_ItemText[aIndex]=aText;
            if(m_Visible){
               if(aIndex>=m_sb.Value() && aIndex<m_sb.Value()+m_HeightInItems){
                  g.SetText(m_Name+"_IT("+IntegerToString(aIndex-m_sb.Value())+")",aText);
                  ChartRedraw();
               }
            }
      }
		/*!	
			Getting the item text by its index.
         \param		int aIndex - item index.					
			\return Item text (string type).
 		*/         
      string Text(int aIndex){
         return(m_ItemText[aIndex]);
      }
		/*!	
			Selecting an item by the index.
         \param		int aIndex - item index.					
 		*/        
      void SetSelected(int aIndex,bool aSelected){
            if(aIndex<0 || aIndex>=ArraySize(m_Itemselected)){
               return;
            }
         m_Itemselected[aIndex]=aSelected;
         m_LastChanged=aIndex;
            if(m_Visible){
               if(aIndex>=m_sb.Value() && aIndex<m_sb.Value()+m_HeightInItems){
                  color m_Clr=m_BgColor;
                  if(aSelected)m_Clr=m_SelColor;               
                  g.SetBgColor(m_Name+"_IT("+IntegerToString(aIndex-m_sb.Value())+")",m_Clr);
                  ChartRedraw();
               }
            }
      }
		/*!	
			Selected item.
         \param		int aIndex - item index.					
         \return bool type. True/false - selected/not selected
 		*/         
      bool Selected(int aIndex){
            if(aIndex>=0 && aIndex<ArraySize(m_Itemselected)){
               return(m_Itemselected[aIndex]);
            }
         return(false);            
      }
		/*!	
			Index of the last selected or last deselected item.
         \return Item index (int type).
 		*/ 
      int LastChanged(){
         return(m_LastChanged);
      }
		/*!	
			Index of the first selected item.
         \return Item index (int type).
 		*/       
      int FirstSelected(){
         m_SearchFrom=0;
         return(NextSelected());
      }
		/*!	
			Index of the next selected item (following the item received at the last call of FirstSelected() or NextSelected()).
         \return Item index (int type).
 		*/       
      int NextSelected(){
            for(int i=m_SearchFrom;i<ArraySize(m_ItemText);i++){
               if(m_Itemselected[i]){
                  m_SearchFrom=i+1;
                  return(i);
               }
            }
         return(-1);
      }
      /*
         // All selected items iteration
         int Selected=lstm.FirstSelected();
            while(Selected!=-1){
               //=======================================
               // An action with the selected item
               Alert(Selected);
               // ======================================
               Selected=lstm.NextSelected();
            }      
      */     
};

//+------------------------------------------------------------------+
//|         CComBox Class                                            |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Combox".
   \details Work in subwindows is supported. 
   \remark	One control consists of the "List" control,
            and two text boxes OBJ_EDIT (one for a value, the other one to be used
            as a button). In order to get the list name, "_Lst" is added to aName,
            "_E" is added for the text box name and "_B" is added for the button name.
*/

class CComBox{
   protected:
      int m_Left;
      int m_Top;
      int m_Width;   
      bool m_Visible;
      string m_Value;
      int m_SubWindow;    
      int m_NpCnt;  
      bool m_ReadOnly;      
      string m_Name;
      string m_NameEdit;
      string m_NameButton;
      string m_NameList;
      string m_ExName[6];
      CList m_lst;
      color m_BgColor;
      color m_TxtColor;
      color m_ButTxtColor;
      color m_ButBgColor;
      color m_FlashColor;
      color m_WarningColor;
      bool m_Warning;
      string m_NameLbl;
      string m_Caption;
      color m_LblColor;
      void Flash(string aName,color aFlash,color aNormal){
         g.SetBgColor(aName,aFlash);
         g.Redraw();
         Sleep(100);
         g.SetBgColor(aName,aNormal);
         g.Redraw();      
      }     
      void Create(){
         color m_tcol=m_BgColor;
         if(m_Warning)m_tcol=m_WarningColor;
         w.Edit(m_NameEdit,m_SubWindow,m_Left,m_Top,m_Width-12,15,m_Value,m_tcol,m_TxtColor);
         g.Attach(m_NameEdit);
         g.SetReadOnly(m_ReadOnly);
         w.Edit(m_NameButton,m_SubWindow,m_Left+m_Width-13,m_Top,13,15," \/",m_ButBgColor,m_ButTxtColor,6);
         g.SetReadOnly(m_NameButton,true);
         m_lst.SetSubWindow(m_SubWindow);
         int m_center=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,m_SubWindow)/2;
            if(m_Top-7>m_center){
               m_lst.SetPos(m_Left,m_Top-m_lst.Height()+1); 
            }
            else{
                m_lst.SetPos(m_Left,m_Top+14);             
            }   
            if(m_Caption!=""){ // Caption is present
               w.Label(m_NameLbl,m_SubWindow,m_Left+m_Width+1,m_Top+2,m_Caption,m_LblColor,7,"Arial"); // Creating a label
            }
      }    
      void Delete(){
         ObjectDelete(0,m_NameEdit);
         ObjectDelete(0,m_NameButton);
         ObjectDelete(0,m_NameLbl);         
      }
   public:
		/*!	
			Control initialization.
            \param		string aName="CComBox" - name,
            \param		int aWidth=100 - width,
            \param		string aCaption="CComBox" - caption text.
 		*/      
      void Init(string aName="CComBox",int aWidth=100,string aCaption="CComBox"){
         m_Visible=false;
         m_Width=aWidth;
         m_Name=aName;
         m_ReadOnly=true;
         m_SubWindow=0;
         m_NpCnt=0;     
         m_Warning=false;    
         m_NameEdit=m_Name+"_E";
         m_NameButton=m_Name+"_B";
         m_NameList=aName+"_Lst";   
         m_NameLbl=aName+"_L";  
         m_ExName[0]=m_Name+"_Lst_SB_LB";
         m_ExName[1]=m_Name+"_Lst_SB_UB";
         m_ExName[2]=m_Name+"_Lst_SB_S";
         m_ExName[3]=m_Name+"_Lst_SB_LF";
         m_ExName[4]=m_Name+"_Lst_SB_UF";
         m_ExName[5]=m_Name+"_B";
         m_Caption=aCaption;
         m_lst.Init(m_NameList,aWidth,1);
         m_lst.SetAllowDeselect(false);
         m_BgColor=ClrScheme.Color(0);       // as in the text box
         m_TxtColor=ClrScheme.Color(1);      // as in the text box
         m_ButTxtColor=ClrScheme.Color(1);   // Button caption color should match the text box border color
         m_ButBgColor=ClrScheme.Color(4);    // Button color as in spin box
         m_FlashColor=ClrScheme.Color(5);    // Flashing color as in spin box
         m_WarningColor=ClrScheme.Color(3);  // Warning color
         m_LblColor=ClrScheme.Color(2);      // Label color
      }
		/*!	
			Clearing the list.
         \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/         
      void Clear(){
         m_lst.Clear();
         m_lst.SetHeightInItems(1); 
         m_Value="";
      }   
		/*!	
			Adding an item to the list.
         \param		string aText - text.			
			\remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/            
      void AddItem(string aItem){
         m_lst.AddItem(aItem);
         m_lst.SetHeightInItems((int)MathMin(8,m_lst.Count()));           
      }
		/*!	
			Deleting an item from the list.
         \param		int aIndex - index of the item to be deleted.			
			\remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void DeleteItem(int aIndex){
         m_lst.DeleteItem(aIndex);
         m_lst.SetHeightInItems((int)MathMin(8,m_lst.Count()));           
      }   
		/*!	
			Number of list items.
			\return Number of elements (int type).
 		*/        
      int Count(){
         return(m_lst.Count());
      }
		/*!	
			Item selection.
         \param		int aIndex - item index.					
 		*/         
      void SetSelectedIndex(int aIndex){
         m_lst.SetSelectedIndex(aIndex);
         m_lst.ScrollTo(aIndex);
         m_Value=m_lst.SelectedText();
            if(m_Visible){
               g.SetText(m_NameEdit,m_Value);
               g.Redraw();
            }
      }
		/*!	
			Setting the value.
         \param		string aValue - text.					
 		*/       
      void SetValue(string aValue){
            for(int i=0;i<m_lst.Count();i++){
               if(aValue==m_lst.Text(i)){
                  SetSelectedIndex(i);
                  return;
               }
            }
         m_lst.SetSelectedIndex(-1);
         m_lst.ScrollTo(0);
         m_Value=aValue;
            if(m_Visible){
               g.SetText(m_NameEdit,m_Value);
               g.Redraw();            
            }
      }
		/*!	
			Setting the item text by its index.
         \param		int aIndex - item index,
         \param		int aText - item text,
 		*/       
      void SetText(int aIndex,string aText){
         m_lst.SetText(aIndex,aText);
            if(aIndex==m_lst.SelectedIndex()){
               m_Value=aText;
                  if(m_Visible){
                     g.SetText(m_NameEdit,m_Value);
                     g.Redraw();            
                  }
            }
      }
		/*!	
			Enabling visibility.
 		*/        
      void Show(){
         m_Visible=true;
         Create();
         ChartRedraw();
      }  
		/*!	
			Control visibility.
			\return bool type. True/false - visible/hidden.
 		*/        
      bool Visible(){
         return(m_Visible);
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }      
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosTop(int aTop){
         m_Top=aTop;
      }   
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/        
      void Show(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         Show();
      }   
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/          
      void Hide(){
         m_Visible=false;
         Delete();
            if(m_lst.Visible()){
               m_lst.Hide();
            }
            else{               
               ChartRedraw(); 
            }               
      }
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/         
      void Refresh(){
         if(m_Visible){
            Delete();
            Create();
            m_lst.Hide();
            ChartRedraw();         
         }            
      }
		/*!	
			Setting the "Read only" property.
			\param int aValue - true/false - read only/editing possible.
 		*/        
      void SetReadOnly(bool aValue){
         m_ReadOnly=aValue;
            if(m_Visible){
               g.Attach(m_NameEdit);
               g.SetReadOnly(m_ReadOnly);
               g.Redraw();
            }
      }
		/*!	
			Getting the "Read only" property.
			\return bool type. True/false - read only/editing possible.
 		*/        
      bool ReadOnly(){
         return(m_ReadOnly);
      }
		/*!	
			Selected item index.
			\return Selected item index (int type), if no selected items present, return -1.
 		*/        
      int SelectedIndex(){
         return(m_lst.SelectedIndex());
      }
		/*!	
			Selected item text.
			\return Selected item text (string type), if no selected items present, return "".
 		*/        
      string SelectedText(){
         return(m_lst.SelectedText());
      }  
		/*!	
			Text box value.
			\return Text (string type).
 		*/         
      string Value(){
         return(m_Value);
      } 
		/*!	
			Getting the width.
			\return  Value (int type).
			\remark  Caption width is not taken into account.
 		*/        
      int Width(){
         return(m_Width);
      }  
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/          
      int Height(){
         return(15);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){
         return(m_Left);      
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/       
      int Top(){
         return(m_Top);        
      }
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of a value modification by a user.
 		*/       
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_event=0;
            if(sparam==""){
               m_NpCnt++;
                  if(m_NpCnt>1){
                     m_lst.Hide();
                  }
            }
            else{
               m_NpCnt=0;
                  if(m_lst.Event(id,lparam,dparam,sparam)==2){
                     g.Attach(m_NameEdit);
                        if(m_lst.SelectedText()!=g.Text()){
                           m_event=1;
                           g.SetText(m_lst.SelectedText());
                           m_Value=g.Text();
                           g.Redraw();
                           
                           Sleep(100);
                        }
                  }
                  if(id==CHARTEVENT_OBJECT_ENDEDIT){
                     if(sparam==m_NameEdit){
                        g.Attach(m_NameEdit);
                           if(m_Value!=g.Text()){
                              m_event=1;
                              m_Value=g.Text();
                              m_lst.SetSelectedIndex(-1);
                                 for(int i=0;i<m_lst.Count();i++){
                                    if(m_Value==m_lst.Text(i)){
                                       m_lst.SetSelectedIndex(i);
                                       m_lst.ScrollTo(i);
                                       break;
                                    }
                                 }
                              
                           }
                     }                        
                  }
                  if(id==CHARTEVENT_OBJECT_CLICK){
                     if(sparam==m_NameButton){
                        Flash(m_NameButton,m_FlashColor,m_ButBgColor);
                           if(m_lst.Visible()){
                              m_lst.Hide();
                           }
                           else{
                              m_lst.Show();
                           }
                     }

                  } 
                  if(
                     !(sparam==m_ExName[0] ||
                     sparam==m_ExName[1] ||
                     sparam==m_ExName[2] ||
                     sparam==m_ExName[3] ||
                     sparam==m_ExName[4] ||
                     sparam==m_ExName[5])
                  ){
                     if(m_lst.Visible()){
                        m_lst.Hide();
                     }           
                  }                                            
            
            }
          return(m_event);
      } 
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/       
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      }    
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/              
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      } 
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/       
      void SetTag(string aValue){
         m_lst.SetTag(aValue);
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/       
      string Tag(){ 
         return(m_lst.Tag());
      }   
		/*!	
			Enabling/disabling the warning color.
			\param bool aValue - true/false (warning/normal). 
 		*/        
      void SetWarning(bool aValue){
            if(m_Visible){
               if(aValue){
                  if(!m_Warning){
                     g.Attach(m_NameEdit);
                     g.SetBgColor(m_WarningColor); 
                  }
               }
               else{
                  if(m_Warning){
                     g.Attach(m_NameEdit);
                     g.SetBgColor(m_BgColor);
                  }
               }
            }
         m_Warning=aValue;
      }
		/*!	
			Getting the warning mode.
			\return bool type. True/false - warning/normal.
 		*/        
      bool Warning(){
         return(m_Warning);
      }                     
};

//+------------------------------------------------------------------+
//|         CHMenu Class                                             |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Horizontal menu".
   \details Work in subwindows is supported. 
   \remark	This control consists of graphical objects, as follows: 
            "Edit" (OBJ_EDIT), four boxes are used as buttons:
            scroll to the start, scroll one "screen" to the left, scroll 
            one "screen" to the right, scroll to the end. The remaining boxes are used
            for menu items. In order to get the button names,
            "_LBB", "_LBS", "_RBS", "_RBB" are added to aName, "_IC" and item
            index in parenthesis are added for item names.
*/

class CHMenu{
   private:
      bool m_Visible;
      string m_Name;
      int m_Left;
      int m_Top;
      int m_Width;
      int m_VisItems;
      int m_DefVisItems;
      int m_Start;
      string m_Items[];
      bool m_Checked[];
      int m_SubWindow;
      string m_NameLBB;
      string m_NameLBS;      
      string m_NameRBB;
      string m_NameRBS;    
      string m_Tag;   
      color m_BgColorOn;
      color m_BgColorOf;
      color m_BgColor;
      color m_TxtColor;
      color m_ButTxtColor;
      color m_ButBgColor;
      color m_ButFlashColor;
      color m_ItemFlashColor;
      color m_WarningColor;
      color m_CheckColor;
      int m_CheckCnt;
      int m_LastClickedX;
      int m_LastClickedY;
      int m_LastClickedQuarter;   
      int m_LastClickedW; 
      string m_LastClickedName1;  
      string m_LastClickedName2; 
      void ScrollTo(){
         if(m_Visible){
            if(ArraySize(m_Items)>0){
               string m_stri;
                  for(int i=0;i<m_VisItems;i++){
                     m_stri=IntegerToString(i);
                     g.Attach(m_Name+"_IT("+m_stri+")");
                     int j=i+m_Start;
                        if(j<ArraySize(m_Items)){
                           g.SetText("    "+m_Items[j]);
                        }
                        else{
                           g.SetText("");
                        }
                     g.Attach(m_Name+"_IC("+m_stri+")");                     
                        if(m_Checked[j]){
                           g.SetText(CharToString(252));
                        }
                        else{
                           g.SetText(" ");
                        }
                  }
            }               
         }
      }
      void Delete(){
         string m_stri;
            for(int i=0;i<m_VisItems;i++){
               m_stri=IntegerToString(i);
               ObjectDelete(0,m_Name+"_IT("+m_stri+")");
               ObjectDelete(0,m_Name+"_IC("+m_stri+")");
            }
         ObjectDelete(0,m_NameLBB);
         ObjectDelete(0,m_NameLBS);
         ObjectDelete(0,m_NameRBS);
         ObjectDelete(0,m_NameRBB);
      }   
      void DefineBgColor(){
         if(m_CheckCnt>0){
            m_BgColor=m_BgColorOn;
            m_ItemFlashColor=m_BgColorOf;
         }
         else{
            m_BgColor=m_BgColorOf;            
            m_ItemFlashColor=m_BgColorOn;
         }        
      }
      void SetBgColor(){
         DefineBgColor();
            for(int i=0;i<m_VisItems;i++){
               string m_stri=IntegerToString(i);
               g.SetBgColor(m_Name+"_IT("+m_stri+")",m_BgColor);
            }
      }      
      void Create(){
         DefineBgColor();
         w.Edit(m_NameLBB,m_SubWindow,m_Left,m_Top,9,15,"I",m_ButBgColor,m_ButTxtColor,7,"Arial");
         g.SetReadOnly(m_NameLBB,true);
         w.Edit(m_NameLBS,m_SubWindow,m_Left+8,m_Top,11,15,"<",m_ButBgColor,m_ButTxtColor,7,"Arial");
         g.SetReadOnly(m_NameLBS,true);
         w.Edit(m_NameRBS,m_SubWindow,m_Left+m_Width-19,m_Top,11,15,">",m_ButBgColor,m_ButTxtColor,7,"Arial");
         g.SetReadOnly(m_NameRBS,true);
         w.Edit(m_NameRBB,m_SubWindow,m_Left+m_Width-9,m_Top,9,15,"I",m_ButBgColor,m_ButTxtColor,7,"Arial");
         g.SetReadOnly(m_NameRBB,true);
         int m_tw=(m_Width-40)/m_VisItems;   
         string m_stri;      
         int m_z3=0;
            for(int i=0;i<m_VisItems;i++){
               int m_z1=i*(m_Width-40+2)/m_VisItems;
               int m_z2=(i+1)*(m_Width-40+2)/m_VisItems;
               m_stri=IntegerToString(i);
               m_z3=m_Left+18+m_z1;
               w.Edit(m_Name+"_IT("+m_stri+")",m_SubWindow,m_z3,m_Top,(m_z2-m_z1+1),15,"",m_BgColor,m_TxtColor);
               g.SetReadOnly(m_Name+"_IT("+m_stri+")",true);
               w.Label(m_Name+"_IC("+m_stri+")",m_SubWindow,m_Left+18+m_z1+3,m_Top+2," ",m_CheckColor,9,"Wingdings"); 
            }
            if(m_VisItems>0){
               m_stri=IntegerToString(m_VisItems-1);
               g.Attach(m_Name+"_IT("+m_stri+")");
               g.SetXSize(m_Left+m_Width-18-m_z3);
            }
      }   
      void Flash(string aName,color aFlash,color aNormal){
         g.SetBgColor(aName,aFlash);
         g.Redraw();
         Sleep(100);
         g.SetBgColor(aName,aNormal);
         g.Redraw();      
      }        
   public:
		/*!	
			Control initialization.
            \param		string aName="CHMenu" - name,
            \param		int aWidth=100 - width,
            \param		int aVisibleItems=3 - number of visible items.
 		*/     
      void Init(string aName="CHMenu",int aWidth=300,int aVisibleItems=3){
         m_BgColorOn=ClrScheme.Color(15);
         m_BgColorOf=ClrScheme.Color(16);
         m_TxtColor=ClrScheme.Color(1);
         m_ButTxtColor=ClrScheme.Color(1);
         m_ButBgColor=ClrScheme.Color(4);
         m_ButFlashColor=ClrScheme.Color(5);
         m_WarningColor=ClrScheme.Color(3); 
         m_CheckColor=ClrScheme.Color(17);
         m_BgColor=m_BgColorOf;
         m_ItemFlashColor=m_BgColorOn;
         m_SubWindow=0;
         m_Visible=false;
         m_Name=aName;
         m_NameLBB=m_Name+"_LBB";
         m_NameLBS=m_Name+"_LBS";      
         m_NameRBB=m_Name+"_RBB";
         m_NameRBS=m_Name+"_RBS";              
         m_Width=aWidth;
         m_VisItems=aVisibleItems;
         m_DefVisItems=aVisibleItems;
         m_Start=0;
         ArrayResize(m_Items,0);
         ArrayResize(m_Checked,0);
         m_Tag="";
         m_CheckCnt=0;
         m_LastClickedX=-1;
         m_LastClickedY=-1;
         m_LastClickedQuarter=-1;
         m_LastClickedW=-1;
         m_LastClickedName1="";
         m_LastClickedName2="";
      }
		/*!	
			Adding an item to the list.
         \param		string aText - text.			
			\remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/      
      void AddItem(string aItem,bool aChecked=false){
         ArrayResize(m_Items,ArraySize(m_Items)+1);
         m_Items[ArraySize(m_Items)-1]=aItem;
         m_VisItems=MathMin(m_DefVisItems,ArraySize(m_Items));
         ArrayResize(m_Checked,ArraySize(m_Checked)+1);
         m_Checked[ArraySize(m_Checked)-1]=aChecked;  
         if(aChecked)m_CheckCnt++;       
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/  
      void Show(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         Show();
      }
		/*!	
			Enabling visibility.
 		*/       
      void Show(){
         m_Visible=true;
         Create();
         ScrollTo();
         ChartRedraw();
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/         
      void Hide(){
         m_Visible=false;
         Delete();
         ChartRedraw();
      }
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/  
      void Refresh(){
         if(m_Visible){
            Delete();
            Show();
         }            
      }   
		/*!	
			Control visibility.
			\return bool type. True/false - visible/hidden.
 		*/       
      bool Visible(){
         return(m_Visible);
      }
		/*!	
			Setting the selected item.
         \param		int aIndex - item index,
         \param		bool aValue - true/false, selected item is marked by a tick,
 		*/  
      void SetChecked(int aIndex,bool aValue){
            if(m_Checked[aIndex] && !aValue){
               m_CheckCnt--; 
            }
            if(!m_Checked[aIndex] && aValue){
               m_CheckCnt++; 
            }            
         m_Checked[aIndex]=aValue;
            if(m_Visible){
               SetBgColor();
               int m_n=aIndex-m_Start;
                  if(m_n>=0 && m_n<m_VisItems){
                     g.Attach(m_Name+"_IC("+IntegerToString(m_n)+")");
                        if(aValue){
                           g.SetText(CharToString(252));   
                        }
                        else{
                           g.SetText(" ");   
                        }
                  }
               ChartRedraw();                  
            }
      }
		/*!	
			Checking whether the item is selected or not.
         \param		int aIndex - item index.	
         \return  bool type. True/false - selected/not selected.				
 		*/        
      bool Checked(int aIndex){
         return(m_Checked[aIndex]);
      }  
		/*!	
			Checking the existence of the selected items.
         \return  bool type. True/false - selected item exists/does not exist.				
 		*/        
      bool CheckedExist(){
         return(m_CheckCnt>0);
      }
		/*!	
			Getting the item text by its index.
         \param		int aIndex - item index.					
			\return Item text (string type).
 		*/   
      string Text(int aIndex){
         return(m_Items[aIndex]);
      }  
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/ 
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }  
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/    
      void SetPosTop(int aTop){
         m_Top=aTop;
      }   
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/    
      int Width(){
         return(m_Width);
      }  
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/  
      int Height(){
         return(15);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/ 
      int Left(){
         return(m_Left);      
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/ 
      int Top(){
         return(m_Top);        
      }
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  -1 - no event. From 0 onwards - index of the clicked item.
 		*/         
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_rv=-1;
            if(id==CHARTEVENT_OBJECT_CLICK){
               if(sparam==m_NameLBB){
                  if(m_Start>0){
                     Flash(m_NameLBB,m_ButFlashColor,m_ButBgColor);
                     m_Start=0;
                     ScrollTo();
                     ChartRedraw();
                  }
                  else{
                     Flash(m_NameLBB,m_WarningColor,m_ButBgColor);
                  }
               }
               if(sparam==m_NameLBS){
                  if(m_Start>0){
                     Flash(m_NameLBS,m_ButFlashColor,m_ButBgColor);                
                     m_Start-=m_VisItems;
                     if(m_Start<0)m_Start=0;
                     ScrollTo();
                     ChartRedraw();
                  }
                  else{
                     Flash(m_NameLBS,m_WarningColor,m_ButBgColor);
                  }                  
               }               
               
               if(sparam==m_NameRBB){
                  if(m_Start<ArraySize(m_Items)-m_VisItems){
                     Flash(m_NameRBB,m_ButFlashColor,m_ButBgColor);                 
                     m_Start=ArraySize(m_Items)-m_VisItems;
                     ScrollTo();
                     ChartRedraw();
                  }
                  else{
                     Flash(m_NameRBB,m_WarningColor,m_ButBgColor);
                  }                  
               }

               if(sparam==m_NameRBS){
                  if(m_Start<ArraySize(m_Items)-m_VisItems){
                     Flash(m_NameRBS,m_ButFlashColor,m_ButBgColor);              
                     m_Start+=m_VisItems;
                     m_Start=MathMin(m_Start,ArraySize(m_Items)-m_VisItems);
                     ScrollTo();
                     ChartRedraw();
                  }
                  else{
                     Flash(m_NameRBS,m_WarningColor,m_ButBgColor);
                  }                  
               }               
               if(StringFind(sparam,m_Name+"_I",0)==0){
                  int m_pos=StringFind(sparam,"(",0);
                  string m_oi=StringSubstr(sparam,m_pos+1,StringLen(sparam)-m_pos-2);
                  m_LastClickedName1=m_Name+"_IT("+m_oi+")";
                  m_LastClickedName2=m_Name+"_IC("+m_oi+")";
                  int m_index=m_Start+(int)StringToInteger(m_oi);
              
                  g.Attach(m_LastClickedName1);
                  m_LastClickedX=g.XDistance();
                  m_LastClickedY=g.YDistance();
                  m_LastClickedW=g.XSize();
                  
                  int m_ocx=g.XDistance()+g.XSize()/2;
                  int m_ocy=g.YDistance()+g.YSize()/2;
                  int m_ccx=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,m_SubWindow)/2;
                  int m_ccy=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,m_SubWindow)/2;
                     if(m_ocy<m_ccy){
                        if(m_ocx<m_ccx){
                           m_LastClickedQuarter=1;
                        }
                        else{
                           m_LastClickedQuarter=2;
                        }
                     }
                     else{
                        if(m_ocx<m_ccx){
                           m_LastClickedQuarter=3;
                        }
                        else{
                           m_LastClickedQuarter=4;                        
                        }                     
                     }
                  Flash(m_LastClickedName1,m_ItemFlashColor,m_BgColor);
                  return(m_index);
               }
            }
         return(m_rv);
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/       
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      }      
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/   
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      } 
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/          
      void SetTag(string aValue){
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/       
      string Tag(){ 
         return(m_Tag);
      }  
		/*!	
			X-coordinate of the item of the last event.
			\return Value (int type).
 		*/  
      int LastClickedX(){
         return(m_LastClickedX);
      }  
		/*!	
			Y-coordinate of the item of the last event.
			\return Value (int type).
 		*/           
      int LastClickedY(){
         return(m_LastClickedY);
      }
		/*!	
			Chart quarter where the item of the last event is located.
			\return Value (int type). 1 - top left, 2 - top right, 3 - bottom left, 4 - bottom right.
 		*/        
      int LastClickedQuarter(){
         return(m_LastClickedQuarter);
      }     
		/*!	
			Width of the item of the last event.
			\return Value (int type).
 		*/        
      int LastClickedW(){
         return(m_LastClickedW);
      }  
		/*!	
			Text box name of the item of the last event.
			\return Text box name (string type).
 		*/   
      string LastClickedName1(){
         return(m_LastClickedName1);
      }
		/*!	
			Label name for the tick symbol of the item of the last event.
			\return Label name (string type).
 		*/       
      string LastClickedName2(){
         return(m_LastClickedName2);
      } 
		/*!	
			X-coordinate for setting of the graphical object displayed at a command of the menu.
			\param int aWidth - width of the displayed object.
			\return X-coordinate (int type).
 		*/   
      int SolvePosLeft(int aWidth){
            if(m_LastClickedQuarter==2 || m_LastClickedQuarter==4){
               return(m_LastClickedX+m_LastClickedW-aWidth);
            }
         return(m_LastClickedX);
      }
		/*!	
			Y-coordinate for setting of the graphical object displayed at a command of the menu.
			\param int aHeight - height of the displayed object.
			\return Y-coordinate (int type).
 		*/        
      int SolvePosTop(int aHeight){
            if(m_LastClickedQuarter==3 || m_LastClickedQuarter==4){
               return(m_LastClickedY-aHeight+1);
            }
         return(m_LastClickedY+Height()-1);            
      }
};

//+------------------------------------------------------------------+
//|         CVMenu Class                                             |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Vertical Menu".
   \details Work in subwindows is supported. 
   \remark	This control consists of graphical objects, as follows: 
            "Edit" (OBJ_EDIT) and the "Vertical Scrollbar" 
            control. In order to get the scrollbar name, "_SB" is added
            to aName, "IT" and the item index in parenthesis are added 
            for text box names.
*/

class CVMenu{
   protected:
      string m_ItemText[];
      bool m_Checked[];
      string m_Name;
      int m_Left;
      int m_Top;
      int m_Width;
      int m_HeightInItems;
      int m_DefHeightInItems;
      int m_Start;
      CVScrollBar m_sb;
      bool m_Visible;
      color m_BgColorOn;
      color m_BgColorOf;
      color m_BgColor;
      color m_TxtColor;
      color m_ButTxtColor;
      color m_ButBgColor;
      color m_ButFlashColor;
      color m_ItemFlashColor;
      color m_WarningColor;
      color m_CheckColor;
      int m_SubWindow;
      int m_CheckCnt;
      string m_Tag;
      int m_LastClickedX;
      int m_LastClickedY;
      int m_LastClickedQuarter;   
      int m_NpCnt;   
      string m_ExName[]; 
      string m_LastClickedName1;
      string m_LastClickedName2;
      void ScrollTo(){
         for(int i=0;i<m_HeightInItems;i++){
            int j=m_Start+i;
               if(j<ArraySize(m_ItemText)){
                  g.Attach(m_Name+"_IT("+IntegerToString(i)+")");
                  g.SetText("    "+m_ItemText[j]);
                  string m_chtxt=" ";
                     if(m_Checked[j]){                     
                        m_chtxt=CharToString(252);
                     }
                  g.Attach(m_Name+"_IC("+IntegerToString(i)+")");
                  g.SetText(m_chtxt);
               }
               else{
                  g.Attach(m_Name+"_IT("+IntegerToString(i)+")");
                  g.SetText(" ");
                  g.Attach(m_Name+"_IC("+IntegerToString(i)+")");
                  g.SetText(" ");                  
               }
         }
      }   
      void DefineBgColor(){
         if(m_CheckCnt>0){
            m_BgColor=m_BgColorOn;
            m_ItemFlashColor=m_BgColorOf;
         }
         else{
            m_BgColor=m_BgColorOf;            
            m_ItemFlashColor=m_BgColorOn;
         }        
      }
      void SetBgColor(){
         DefineBgColor();
            for(int i=0;i<m_HeightInItems;i++){
               string m_stri=IntegerToString(i);
               g.SetBgColor(m_Name+"_IT("+m_stri+")",m_BgColor);
            }
      }  

      void Create(){
         m_NpCnt=0;
         DefineBgColor();
         int m_w=m_Width;
            if(ArraySize(m_ItemText)>m_HeightInItems){
               m_w=m_Width-m_sb.Width();
               m_sb.Show(m_Left+m_w,m_Top);
               m_w++;
            }      
            for(int i=0;i<m_HeightInItems;i++){
               w.Edit(m_Name+"_IT("+IntegerToString(i)+")",m_SubWindow,m_Left,m_Top+i*14,m_w,15," ",m_BgColor,m_TxtColor,7,"Arial");
               g.SetReadOnly(m_Name+"_IT("+IntegerToString(i)+")",true);
               w.Label(m_Name+"_IC("+IntegerToString(i)+")",m_SubWindow,m_Left+3,m_Top+i*14+2," ",m_CheckColor,9,"Wingdings");                     
            }
         m_sb.SetSubWindow(m_SubWindow);            
      }
      void Delete(){
         for(int i=0;i<m_HeightInItems;i++){
            ObjectDelete(0,m_Name+"_IT("+IntegerToString(i)+")");
            ObjectDelete(0,m_Name+"_IC("+IntegerToString(i)+")");               
         }
      }
      void Flash(string aName,color aFlash,color aNormal){
         g.SetBgColor(aName,aFlash);
         g.Redraw();
         Sleep(100);
         g.SetBgColor(aName,aNormal);
         g.Redraw();      
      }         
   public:
		/*!	
			Control initialization.
            \param		string aName="CVMenu" - name,
            \param		int aWidth=100 - width,
            \param		int aVisibleItems=10 - number of visible items.
 		*/      
      void Init(string aName="CVMenu",int aWidth=100,int aVisibleItems=10){
         m_BgColorOn=ClrScheme.Color(15);
         m_BgColorOf=ClrScheme.Color(16);
         m_TxtColor=ClrScheme.Color(1);
         m_ButTxtColor=ClrScheme.Color(1);
         m_ButBgColor=ClrScheme.Color(4);
         m_ButFlashColor=ClrScheme.Color(5);
         m_WarningColor=ClrScheme.Color(3); 
         m_CheckColor=ClrScheme.Color(17);
         m_SubWindow=0;
         m_CheckCnt=0;
         m_Visible=false;
         m_Name=aName;
         m_Width=aWidth;
         m_HeightInItems=aVisibleItems;
         m_DefHeightInItems=aVisibleItems;
         m_Left=0;
         m_Top=0;
         m_Start=0;
         ArrayResize(m_ItemText,0);
         ArrayResize(m_Checked,0);
         m_sb.Init(aName+"_SB",aVisibleItems*14+1,1);
         m_sb.SetMin(0);
         m_sb.SetValue(0);
         m_sb.SetSmallChange(1);
         m_sb.SetLageChange(aVisibleItems);
         m_Tag="";
         m_LastClickedX=-1;
         m_LastClickedY=-1;
         m_LastClickedQuarter=-1;  
         m_NpCnt=0;
         ArrayResize(m_ExName,0);
         m_LastClickedName1="";
         m_LastClickedName2="";
      }
		/*!	
			Adding a toggle name.
         \param		string aValue - name of the graphical object that is used to enable/disable menu visibility.			
 		*/ 
      void ToggleNameAdd(string aValue){
         ArrayResize(m_ExName,ArraySize(m_ExName)+1);
         m_ExName[ArraySize(m_ExName)-1]=aValue;
      }
		/*!	
			Clearing the list of toggle names.
 		*/       
      void ToggleNamesClear(){
         ArrayResize(m_ExName,0);
      }
		/*!	
			Adding an item to the list.
         \param		string aText - text.			
			\remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/          
      void AddItem(string aText,bool aChecked=false){
         ArrayResize(m_ItemText,ArraySize(m_ItemText)+1);
         m_ItemText[ArraySize(m_ItemText)-1]=aText;
         ArrayResize(m_Checked,ArraySize(m_Checked)+1);
         m_Checked[ArraySize(m_Checked)-1]=aChecked;
         m_HeightInItems=MathMin(m_DefHeightInItems,ArraySize(m_ItemText));
            if(ArraySize(m_ItemText)>m_HeightInItems){
               m_sb.SetMax(ArraySize(m_ItemText)-m_HeightInItems);
            }
         if(aChecked)m_CheckCnt++;                
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/ 
      void Show(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         Show();
      }
		/*!	
			Enabling visibility.
 		*/        
      void Show(){
         m_Visible=true;
         Create();
         ScrollTo();            
         ChartRedraw(0);
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/        
      void Hide(){
         m_Visible=false;
         Delete();
            if(m_sb.Visible()){
               m_sb.Hide();
            }
            else{
               ChartRedraw();
            }               
      }
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refresh(){
         if(m_Visible){
            Delete();
               if(m_sb.Visible()){
                  m_sb.Hide();
               }
            Show();
         }            
      }
		/*!	
			Control visibility.
			\return bool type. True/false - visible/hidden.
 		*/      
      bool Visible(){
         return(m_Visible);
      }
		/*!	
			Setting the selected item.
         \param		int aIndex - item index,
         \param		bool aValue - true/false, selected item is marked by a tick.
 		*/        
      void SetChecked(int aIndex,bool aValue){
            if(m_Checked[aIndex] && !aValue){
               m_CheckCnt--; 
            }
            if(!m_Checked[aIndex] && aValue){
               m_CheckCnt++; 
            }        
         m_Checked[aIndex]=aValue;
            if(m_Visible){
               SetBgColor();
               int m_n=aIndex-m_Start;
                  if(m_n>=0 && m_n<m_HeightInItems){
                     g.Attach(m_Name+"_IC("+IntegerToString(m_n)+")");
                        if(aValue){
                           g.SetText(CharToString(252));   
                        }
                        else{
                           g.SetText(" ");   
                        }
                  }
               ChartRedraw();
            }
      }
		/*!	
			Checking whether the item is selected or not.
         \param		int aIndex - item index.	
         \return  bool type. True/false - selected/not selected.				
 		*/        
      bool Checked(int aIndex){
         return(m_Checked[aIndex]);
      }  
		/*!	
			Checking the existence of the selected items.
         \return  bool type. True/false - selected item exists/does not exist.				
 		*/ 
      bool CheckedExist(){
         return(m_CheckCnt>0);
      }
		/*!	
			Getting the item text by its index.
         \param		int aIndex - item index.					
			\return Item text (string type).
 		*/   
      string Text(int aIndex){
         return(m_ItemText[aIndex]);
      } 
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/ 
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }  
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/            
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosTop(int aTop){
         m_Top=aTop;
      }
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/       
      int Width(){
         return(m_Width);
      }   
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/
      int Height(){
         return(m_HeightInItems*14+1);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){
         return(m_Left);      
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/       
      int Top(){
         return(m_Top);        
      }
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  -1 - no event. From 0 onwards - index of the clicked item.
 		*/  
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
            if(m_sb.Event(id,lparam,dparam,sparam)==1){
               m_Start=m_sb.Value();
               ScrollTo();
               ChartRedraw();
               m_NpCnt=0;
               return(-1);
            }
            if(
               sparam==m_Name+"_SB_LB" ||
               sparam==m_Name+"_SB_UB" ||
               sparam==m_Name+"_SB_S" ||
               sparam==m_Name+"_SB_LF" ||
               sparam==m_Name+"_SB_UF"
            ){
               m_NpCnt=0;
               return(-1);
            }
            
            if(id==CHARTEVENT_OBJECT_CLICK){
               if(StringFind(sparam,m_Name+"_I",0)==0){
                  m_NpCnt=0;
                  
                  int m_pos=StringFind(sparam,"(",0);
                  string m_oi=StringSubstr(sparam,m_pos+1,StringLen(sparam)-m_pos-2);
                  int m_index=m_Start+(int)StringToInteger(m_oi);
                  m_LastClickedName1=m_Name+"_IT("+m_oi+")";
                  m_LastClickedName2=m_Name+"_IC("+m_oi+")";
                  
                  g.Attach(m_LastClickedName1);
                  m_LastClickedX=g.XDistance();
                  m_LastClickedY=g.YDistance();
                  
                  int m_ocx=g.XDistance()+g.XSize()/2;
                  int m_ocy=g.YDistance()+g.YSize()/2;
                  int m_ccx=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,m_SubWindow)/2;
                  int m_ccy=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,m_SubWindow)/2;
                     if(m_ocy<m_ccy){
                        if(m_ocx<m_ccx){
                           m_LastClickedQuarter=1;
                        }
                        else{
                           m_LastClickedQuarter=2;
                        }
                     }
                     else{
                        if(m_ocx<m_ccx){
                           m_LastClickedQuarter=3;
                        }
                        else{
                           m_LastClickedQuarter=4;                        
                        }                     
                     }               
                  Flash(m_LastClickedName1,m_ItemFlashColor,m_BgColor);
                  
                  return(m_index);
               }
            }
            
         m_NpCnt++;

            if(ArraySize(m_ExName)==0){
               m_NpCnt=0;
            }
            else{
               for(int i=0;i<ArraySize(m_ExName);i++){
                  if(sparam==m_ExName[i]){
                     m_NpCnt=0;
                     break;
                  }
               }
            }
            if(m_NpCnt>1){
               m_NpCnt=0;
               Hide();
            }
            
         return(-1);
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/         
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               m_sb.SetSubWindow(m_SubWindow);
               Refresh();
            }
      }  
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/                
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      } 
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/        
      void SetTag(string aValue){
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/        
      string Tag(){ 
         return(m_Tag);
      }    
		/*!	
			X-coordinate of the item of the last event.
			\return Value (int type).
 		*/  
      int LastClickedX(){
         return(m_LastClickedX);
      }  
		/*!	
			Y-coordinate of the item of the last event.
			\return Value (int type).
 		*/           
      int LastClickedY(){
         return(m_LastClickedY);
      }
		/*!	
			Chart quarter where the item of the last event is located.
			\return Value (int type). 1 - top left, 2 - top right, 3 - bottom left, 4 - bottom right.
 		*/        
      int LastClickedQuarter(){
         return(m_LastClickedQuarter);
      }  
      /*!	
			Text box name of the item of the last event.
			\return Text box name (string type).
 		*/   
      string LastClickedName1(){
         return(m_LastClickedName1);
      } 
		/*!	
			Label name for the tick symbol of the item of the last event.
			\return Label name (string type).
 		*/       
      string LastClickedName2(){
         return(m_LastClickedName2);
      }   	 		
		/*!	
			An item height.
			\return Value (int type).
 		*/ 		     
      int ItemHeight(){
         return(15);
      }  
		/*!	
			X-coordinate for setting of the graphical object displayed at a command of the menu.
			\param int aWidth - width of the displayed object.
			\return X-coordinate (int type).
 		*/   
      int SolvePosLeft(int aWidth){
            if(m_LastClickedQuarter==2 || m_LastClickedQuarter==4){
               return(m_LastClickedX-aWidth+1);
            }
         return(m_LastClickedX+Width()-1);
      }
		/*!	
			Y-coordinate for setting of the graphical object displayed at a command of the menu.
			\param int aHeight - height of the displayed object.
			\return Y-coordinate (int type).
 		*/        
      int SolvePosTop(int aHeight){
            if(m_LastClickedQuarter==3 || m_LastClickedQuarter==4){
               return(m_LastClickedY+ItemHeight()-aHeight);
               
            }
         return(m_LastClickedY);            
      }      
};

//+------------------------------------------------------------------+
//|         CHProgress Class                                             |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Horizontal Progress Bar".
   \details Work in subwindows is supported. 
   \remark	This control consists of two graphical objects 
            "Edit" (OBJ_EDIT) (background and a bar) and two labels 
            (OBJ_LABEL) for display of progress in percent and the remaining
            time. In order to get the button names,
            "_C1", "_C2", "_L1", "_L2" are added to aName.
*/



class CHProgress{
   protected:
      bool m_Started;
      string m_Name;
      string m_NameC1;
      string m_NameC2;
      string m_NameL1;
      string m_NameL2;
      int m_Left;
      int m_Top;
      int m_Width;
      int m_Height;
      double m_Min;
      double m_Max;
      double m_Value;
      int m_Digits;
      bool m_Visible;
      int m_Len;
      uint m_St;
      ulong m_Add;
      int m_RefreshInterval;
      datetime m_LastTime;
      color m_BgColor;
      color m_BorderColor;
      color m_ProgrColor;
      color m_TxtColor;
      int m_SubWindow;
      string m_Tag;
      string FormatSec(long aSec){
         string m_rs="";
         long m_h=aSec/3600;
         aSec-=m_h*3600;
         long m_m=aSec/60;
         aSec-=m_m*60;
            if(m_h>0){
               if(m_h<10){
                  m_rs="0"+IntegerToString(m_h)+":";
               }
               else{
                  m_rs=IntegerToString(m_h)+":";
               }
            }
           
            if(m_m<10){
               m_rs=m_rs+"0"+IntegerToString(m_m)+":";
            }
            else{
               m_rs=m_rs+IntegerToString(m_m)+":";
            }
            if(aSec<10){
               m_rs=m_rs+"0"+IntegerToString(aSec);
            }
            else{
               m_rs=m_rs+IntegerToString(aSec);
            } 
         return(m_rs);                       
      }
      void Labels(){
         double m_done=(m_Value-m_Min)/(m_Max-m_Min);
         m_Len=(int)MathRound(m_done*(m_Width-2));
         g.Attach(m_NameC2);               
         g.SetXSize(m_Len);       
         g.Attach(m_NameL1);
         g.SetText(DoubleToString(m_done*100.0,2)+"%");                 
            if(m_Started){
               uint m_tcn=GetTickCount();
               ulong m_tms;
                  if(m_tcn<m_St){
                     m_Add=ULONG_MAX-m_St;
                     m_St=0;
                  }
               m_tms=m_Add+(m_tcn-m_St);
               long m_lt=0;
               if(m_done>0)m_lt=(int)MathRound(1.0+0.001*m_tms*(1.0-m_done)/m_done);
               g.Attach(m_NameL2);
               g.SetText(FormatSec(m_lt));               
            }                     
    
      }      
      void Create(){
         w.Edit(m_NameC1,m_SubWindow,m_Left,m_Top,m_Width,m_Height," ",m_BgColor,m_BorderColor);
         g.SetReadOnly(m_NameC1,true);
         w.Edit(m_NameC2,m_SubWindow,m_Left+1,m_Top+1,m_Len,m_Height-2," ",m_ProgrColor,m_ProgrColor);  
         g.SetReadOnly(m_NameC2,true);
         w.Label(m_NameL1,m_SubWindow,m_Left+4,m_Top+2," ",m_TxtColor,7);
         w.Label(m_NameL2,m_SubWindow,m_Left+m_Width-4,m_Top+2," ",m_TxtColor,7); 
         g.SetAnchor(m_NameL2,ANCHOR_RIGHT_UPPER);
         //Labels();
      }
      void Delete(){
         g.Delete(m_NameC1);
         g.Delete(m_NameC2); 
         g.Delete(m_NameL1);
         g.Delete(m_NameL2);  
      }
   public:
		/*!	
			Control initialization.
            \param		string aName="CHProgress" - name,
            \param		int aWidth=200 - width.
 		*/    
      void Init(string aName="CHProgress",int aWidth=200){
         m_Name=aName;
         m_NameC1=m_Name+"_C1";
         m_NameC2=m_Name+"_C2";
         m_NameL1=m_Name+"_L1";
         m_NameL2=m_Name+"_L2";      
         m_Visible=false;
         m_Name=aName;
         m_Min=0;
         m_Max=100;
         m_Width=aWidth;
         m_Height=15;
         m_Value=0;
         m_Len=0;
         m_RefreshInterval=0;  
         m_BgColor=ClrScheme.Color(18);
         m_BorderColor=ClrScheme.Color(19);
         m_ProgrColor=ClrScheme.Color(20);
         m_TxtColor=ClrScheme.Color(21);
         m_SubWindow=0;
         m_Tag="";
      }
		/*!	
			Setting a refresh interval.
         \param		int aSeconds - refresh interval in seconds.
 		*/        
      void SetRefreshInterval(int aSeconds){
         m_RefreshInterval=aSeconds;
      }
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetWidth(int aWidth){
         m_Width=aWidth;
      }
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refersh(){
         if(m_Visible){
            Hide();
            Show();
         }
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }   
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/           
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosTop(int aTop){
         m_Top=aTop;
      }   
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/         
      int Width(){
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/       
      int Height(){
         return(15);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/       
      int Top(){
         return(m_Top);
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/        
      void Show(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         Show();
      }
		/*!	
			Enabling visibility.
 		*/   
      void Show(){
         m_Visible=true;
         Create();
         ChartRedraw();
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/         
      void Hide(){
         m_Visible=false;
         Delete();                
         ChartRedraw();
      }  
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refresh(){
         if(m_Visible){
            Delete();
            Show();
         }            
      }    
		/*!	
			Method for starting to use a progress bar. It is called right before the loop 
			whose progress is required to be displayed.
         \param		double aMin=0 - initial value,
         \param		double aMax=100 - finite value.
 		*/        
      void Begin(double aMin=0,double aMax=100){
         Reset();  
         m_Started=true;
         m_Min=aMin;
         m_Max=aMax;
         m_St=GetTickCount();
         m_Add=0;
         m_Value=m_Min;
      }  
		/*!	
			Reset upon completion of the controlled loop. 
 		*/         
      void Reset(){
         m_Started=false;
         m_Value=m_Min;
            if(m_Visible){
               g.SetXSize(m_NameC2,0);            
               g.SetText(m_NameL1," ");
               g.SetText(m_NameL2," ");
               g.Redraw();
            }
      }
		/*!	
			Setting the value. It is called from the controlled loop. 
         param		double aValue - value.
 		*/       
      void SetValue(double aValue){
         m_Value=aValue;
         if(TimeLocal()<m_LastTime+m_RefreshInterval)return;
         m_LastTime=TimeLocal();
            if(m_Visible){
               Labels();
               ChartRedraw();
            }
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/         
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      }   
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/               
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      } 
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/         
      void SetTag(string aValue){
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/         
      string Tag(){ 
         return(m_Tag);
      } 
};

//+------------------------------------------------------------------+
//|        CDialer Class                                            |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Dialer".
   \details It is used as a part of the "Dialer with 
            Input Box" control. Work in subwindows is supported. 
   \remark	This control consists of graphical objects, as follows:  
            (OBJ_EDIT). In order to get the background object name,
            "_Frame" is added to aName,
            "_B1", "_B2", "_B3", "_B4", "_B5", "_B6", "_B7", "_B8",
            "_B9", "_B0" (numbers), "_BD" (decimal point), "_BX" (close),
            "_BC" (cancel), "_BE" (OK), "_M" (minus), "_T" (box where
            an entered value is displayed) are added for buttons.
*/

class CDialer{
   private:
      string m_NameFrame;
      string m_Name1;
      string m_Name2;
      string m_Name3;
      string m_Name4;
      string m_Name5;
      string m_Name6;
      string m_Name7;
      string m_Name8;
      string m_Name9;
      string m_Name0; 
      string m_NameD;
      string m_NameX;
      string m_NameC;
      string m_NameE;
      string m_NameT;
      string m_NameM;      
      int m_ButtonSize;
      int m_TextSize; 
      int m_Left;
      int m_Top;
      color m_BGColor;
      color m_BorderColor;      
      color m_ButDigTxColor;      
      color m_ButDigBgColor;
      color m_ButDigCtrlBgColor;
      color m_ButDigOkBgColor;
      color m_ButDigClColor;      
      color m_TxBgColor;
      color m_TxTxColor;
      color m_WrongFlashColor;
      bool m_Visible;
      int m_Width;
      int m_Height;  
      double m_Value;   
      string m_Tag;
      int m_SubWindow;      
      void Flash(string aName,color aColor){
         g.Attach(aName);
         color restc=g.BgColor();
         g.SetBgColor(aColor);
         g.Redraw();
         Sleep(100);
         g.SetBgColor(restc);
         g.Redraw(); 
      }
      void Push(string aName){
         g.Attach(aName);
         int m_x=g.XDistance();
         int m_y=g.YDistance();
         g.SetXDistance(m_x+1);
         g.SetYDistance(m_y+1);   
         g.Redraw();
         Sleep(100);
         g.SetXDistance(m_x);
         g.SetYDistance(m_y);
         g.Redraw();                                
      }      
      void Create(){
         w.Edit(m_NameFrame,m_SubWindow,m_Left,m_Top,m_Width,m_Height," ",m_BGColor,m_BorderColor);
         w.Edit(m_Name7,m_SubWindow,m_Left+2,m_Top+2,m_ButtonSize,m_ButtonSize," 7",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_Name8,m_SubWindow,m_Left+m_ButtonSize+4,m_Top+2,m_ButtonSize,m_ButtonSize," 8",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_Name9,m_SubWindow,m_Left+6+m_ButtonSize*2,m_Top+2,m_ButtonSize,m_ButtonSize," 9",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_Name4,m_SubWindow,m_Left+2,m_Top+4+m_ButtonSize,m_ButtonSize,m_ButtonSize," 4",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_Name5,m_SubWindow,m_Left+4+m_ButtonSize,m_Top+4+m_ButtonSize,m_ButtonSize,m_ButtonSize," 5",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_Name6,m_SubWindow,m_Left+6+2*m_ButtonSize,m_Top+4+m_ButtonSize,m_ButtonSize,m_ButtonSize," 6",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_Name1,m_SubWindow,m_Left+2,m_Top+6+2*m_ButtonSize,m_ButtonSize,m_ButtonSize," 1",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_Name2,m_SubWindow,m_Left+4+m_ButtonSize,m_Top+6+2*m_ButtonSize,m_ButtonSize,m_ButtonSize," 2",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_Name3,m_SubWindow,m_Left+6+2*m_ButtonSize,m_Top+6+2*m_ButtonSize,m_ButtonSize,m_ButtonSize," 3",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_Name0,m_SubWindow,m_Left+2,m_Top+8+3*m_ButtonSize,2*m_ButtonSize+2,m_ButtonSize," 0",m_ButDigBgColor,m_ButDigTxColor,8);
         w.Edit(m_NameD,m_SubWindow,m_Left+6+2*m_ButtonSize,m_Top+8+3*m_ButtonSize,m_ButtonSize,m_ButtonSize,"    '",m_ButDigBgColor,m_ButDigTxColor,5);
         w.Edit(m_NameX,m_SubWindow,m_Left+8+3*m_ButtonSize,m_Top+2,m_ButtonSize,m_ButtonSize," X",m_ButDigClColor,m_ButDigTxColor,8);
         w.Edit(m_NameC,m_SubWindow,m_Left+8+3*m_ButtonSize,m_Top+4+m_ButtonSize,m_ButtonSize,m_ButtonSize," C",m_ButDigCtrlBgColor,m_ButDigTxColor,8);
         w.Edit(m_NameM,m_SubWindow,m_Left+8+3*m_ButtonSize,m_Top+6+2*m_ButtonSize,m_ButtonSize,m_ButtonSize," -",m_ButDigBgColor,m_ButDigTxColor,10);
         w.Edit(m_NameE,m_SubWindow,m_Left+8+3*m_ButtonSize,m_Top+8+3*m_ButtonSize,m_ButtonSize,m_ButtonSize,"OK",m_ButDigOkBgColor,m_ButDigTxColor,7);
         w.Edit(m_NameT,m_SubWindow,m_Left+2,m_Top+10+4*m_ButtonSize,4*m_ButtonSize+6,m_TextSize,"",m_TxBgColor,m_TxTxColor,7);
         g.SetReadOnly(m_NameFrame,true);
         g.SetReadOnly(m_Name7,true);
         g.SetReadOnly(m_Name8,true);
         g.SetReadOnly(m_Name9,true);
         g.SetReadOnly(m_Name4,true);
         g.SetReadOnly(m_Name5,true);
         g.SetReadOnly(m_Name6,true);
         g.SetReadOnly(m_Name1,true);
         g.SetReadOnly(m_Name2,true);
         g.SetReadOnly(m_Name3,true);
         g.SetReadOnly(m_Name0,true);
         g.SetReadOnly(m_NameD,true);
         g.SetReadOnly(m_NameX,true);
         g.SetReadOnly(m_NameC,true);
         g.SetReadOnly(m_NameM,true);
         g.SetReadOnly(m_NameE,true);
         g.SetReadOnly(m_NameT,true);      
      }  
      void Delete(){
         g.Delete(m_NameFrame);
         g.Delete(m_Name1);
         g.Delete(m_Name2);
         g.Delete(m_Name3);
         g.Delete(m_Name4);
         g.Delete(m_Name5);
         g.Delete(m_Name6);
         g.Delete(m_Name7);
         g.Delete(m_Name8);
         g.Delete(m_Name9);
         g.Delete(m_Name0);
         g.Delete(m_NameD);
         g.Delete(m_NameX);
         g.Delete(m_NameC);
         g.Delete(m_NameE);
         g.Delete(m_NameT);
         g.Delete(m_NameM);         
      }
   public:
		/*!	
			Control initialization.
            \param		string aName="CDialer" - name.
 		*/     
      void Init(string aName="CDialer"){
         m_NameFrame=aName+"_Frame";
         m_Name1=aName+"_B1";
         m_Name2=aName+"_B2";
         m_Name3=aName+"_B3";
         m_Name4=aName+"_B4";
         m_Name5=aName+"_B5";
         m_Name6=aName+"_B6";
         m_Name7=aName+"_B7";
         m_Name8=aName+"_B8";
         m_Name9=aName+"_B9";
         m_Name0=aName+"_B0";      
         m_NameD=aName+"_BD";        
         m_NameX=aName+"_BX";       
         m_NameC=aName+"_BC";   
         m_NameE=aName+"_BE";  
         m_NameT=aName+"_T"; 
         m_NameM=aName+"_M";          
         m_ButtonSize=20;
         m_TextSize=15;   
         m_BGColor=ClrScheme.Color(22);
         m_BorderColor=ClrScheme.Color(23);
         m_ButDigBgColor=ClrScheme.Color(24);
         m_ButDigTxColor=ClrScheme.Color(25);
         m_ButDigCtrlBgColor=ClrScheme.Color(26);
         m_ButDigOkBgColor=ClrScheme.Color(27);
         m_ButDigClColor=ClrScheme.Color(28);
         m_TxBgColor=ClrScheme.Color(29);
         m_TxTxColor=ClrScheme.Color(30);
         m_WrongFlashColor=ClrScheme.Color(31);
         m_Width=4*m_ButtonSize+10;
         m_Height=4*m_ButtonSize+12+m_TextSize;         
         m_Visible=false;
         m_SubWindow=0;
      }  
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/       
      void SetTag(string aTag){
         m_Tag=aTag;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/       
      string Tag(){
         return(m_Tag);
      }    
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/          
      void Show(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         Show();
      }
		/*!	
			Enabling visibility.
 		*/         
      void Show(){
         m_Visible=true;       
         Create();
         ChartRedraw();
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/       
      void Hide(){
         m_Visible=false;
         Delete();
         ChartRedraw();
      }
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/       
      void Refresh(){
         if(m_Visible){
            Delete();
            Show();
         }            
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;    
         m_Top=aTop;           
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosTop(int aTop){
         m_Top=aTop;
      }   
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/          
      int Width(){
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/        
      int Height(){
         return(m_Height);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/       
      int Top(){
         return(m_Top);
      }
		/*!	
			Control visibility.
			\return bool type. True/false - visible/hidden.
 		*/          
      bool Visible(){
         return(m_Visible);
      }
		/*!	
			Last entered value.
			\return Value (double type).
 		*/        
      double Value(){
         return(m_Value);
      }
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – new value entered.
 		*/         
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_rv=0;
            if(id==CHARTEVENT_OBJECT_CLICK){
               if(sparam==m_Name1){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"1"); 
                  g.Redraw();   
                  m_rv=2;               
               }
               if(sparam==m_Name2){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"2"); 
                  g.Redraw();   
                  m_rv=2;                
               }  
               if(sparam==m_Name3){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"3"); 
                  g.Redraw();   
                  m_rv=2;                 
               }
               if(sparam==m_Name4){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"4"); 
                  g.Redraw(); 
                  m_rv=2;                  
               }              
               if(sparam==m_Name5){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"5"); 
                  g.Redraw(); 
                  m_rv=2;                 
               }
               if(sparam==m_Name6){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"6"); 
                  g.Redraw();  
                  m_rv=2;               
               }  
               if(sparam==m_Name7){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"7"); 
                  g.Redraw(); 
                  m_rv=2;                
               }
               if(sparam==m_Name8){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"8"); 
                  g.Redraw();
                  m_rv=2;                 
               }    
               if(sparam==m_Name9){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"9"); 
                  g.Redraw();   
                  m_rv=2;            
               }
               if(sparam==m_Name0){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText(g.Text()+"0"); 
                  g.Redraw();
                  m_rv=2;   
               }  
               if(sparam==m_NameD){
                  g.Attach(m_NameT);
                     if(StringFind(g.Text(),".",0)==-1){
                        Push(sparam);
                        g.Attach(m_NameT);
                        if(g.Text()=="" || g.Text()=="-")g.SetText(g.Text()+"0");
                        g.SetText(g.Text()+"."); 
                        g.Redraw();
                     }
                     else{
                        Flash(sparam,m_WrongFlashColor);
                     }
                  m_rv=2;                        
               }
               if(sparam==m_NameX){
                  Push(sparam);
                  Hide();
                  m_rv=2;   
               }
               if(sparam==m_NameC){
                  Push(sparam);
                  g.Attach(m_NameT);
                  g.SetText("");
                  g.Redraw();
                  m_rv=2;   
               }  
               if(sparam==m_NameE){
                  Push(sparam);
                  g.Attach(m_NameT);
                  string sVal=g.Text();
                  m_Value=StringToDouble(sVal);
                  Hide();
                  m_rv=1;
               }  
               if(sparam==m_NameM){
                  Push(sparam);
                  g.Attach(m_NameT);
                     if(StringSubstr(g.Text(),0,1)=="-"){
                        g.SetText(StringSubstr(g.Text(),1,StringLen(g.Text())-1));
                     }
                     else{
                        g.SetText("-"+g.Text());
                     }
                  g.Redraw();
                  m_rv=2;   
               }   
               if(sparam==m_NameFrame){
                  m_rv=2;
               }
               if(sparam==m_NameT){
                  m_rv=2;
               }  
            }             
         return(m_rv);      
      }
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/         
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               Refresh();
            }
      } 
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/               
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }      
};

//+------------------------------------------------------------------+
//|         CDialerInputBox Class                                    |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Dialer with Input Box".
   \details Work in subwindows is supported. 
   \remark	This control consists of the following controls:
            "Input Box", "Dialer", text boxes for display
            of an entered value and a button (OBJ_EDIT) and a label (OBJ_LABEL).
            In order to get the dialer name, "_D" is added to aName, 
            "_I" is added for the input box, "_B" is added for a "button", "_L" is added for a "label".
*/

class CDialerInputBox{
   private:
      int m_SubWindow;
      int m_Left;
      int m_Top;
      int m_Width;
      int m_Height;
      string m_DName;
      string m_IName;
      string m_BName;
      string m_LName;
      string m_Caption;
      CDialer m_d;
      CInputBox m_ib;
      color m_ColDBg;
      color m_ColDTx;
      color m_ColL;
      int m_cc;
      bool m_Visible;
      string m_Tag;
         void Create(){
            w.Edit(m_BName,m_SubWindow,m_Left+m_Width-13,m_Top,13,m_Height,"d",m_ColDBg,m_ColDTx,7,"Arial");
            g.SetReadOnly(m_BName,true);               
               if(m_Caption!=""){ // Caption is present
                  w.Label(m_LName,m_SubWindow,m_Left+m_Width+1,m_Top+2,m_Caption,m_ColL,7,"Arial"); // Creating a label
               } 
         }      
         void Delete(){
            ObjectDelete(0,m_BName);
            ObjectDelete(0,m_LName);            
         }
   public:
		/*!	
			Control initialization.
            \param		string aName="CDialerInputBox" - name,
            \param		int aWidth=50 - width,
            \param		int aDigits=4 - number of decimal places,
            \param		string aCaption="CDialerInputBox" - caption text.
 		*/      
      void Init(string aName="CDialerInputBox",int aWidth=50,int aDigits=4,string aCaption="CDialerInputBox"){
         m_ColDBg=ClrScheme.Color(4);  // As in spin box
         m_ColDTx=ClrScheme.Color(1);
         m_ColL=ClrScheme.Color(2);
         m_Visible=false;
         m_Left=0;
         m_Top=0;
         m_Width=aWidth;
         m_Height=15;
         m_Caption=aCaption;
         m_DName=aName+"_D";
         m_IName=aName+"_I";
         m_BName=aName+"_B";
         m_LName=aName+"_L";
         m_ib.Init(m_IName,m_Width-12,aDigits,""); // Input box initialization
         m_ib.SetReadOnly(true);
         m_d.Init(m_DName);
         m_cc=0;
         m_Tag="";
      }
		/*!	
			Setting the "Read only" property.
			\param int aValue - true/false - read only/editing possible.
 		*/         
      void SetReadOnly(bool aValue){
         m_ib.SetReadOnly(aValue);
      }
		/*!	
			Getting the "Read only" property.
			\return bool type. True/false - read only/editing possible.
 		*/       
      bool ReadOnly(){
         return(m_ib.ReadOnly());
      }
		/*!	
			Setting the number of decimal places.
			\param int aValue - number of decimal places.
 		*/         
      void SetDigits(int aValue){
         m_ib.SetDigits(aValue);
      }
		/*!	
			Getting the number of decimal places.
			\return int type.
			\remark Defined by the step value.
 		*/         
      int Digits(){
         return(m_ib.Digits());
      }  
		/*!	
			Setting the minimum acceptable value.
			\param double aValue - minimum acceptable value. 
 		*/            
      void SetMinValue(double aValue){
         m_ib.SetMinValue(aValue);
      }
		/*!	
			Getting the minimum acceptable value.
			\return Value (double type).
 		*/        
      double MinValue(){
         return(m_ib.MinValue());
      }
		/*!	
			Setting the maximum acceptable value.
			\param double aValue - maximum acceptable value. 
 		*/        
      void SetMaxValue(double aValue){
         m_ib.SetMaxValue(aValue);      
      }
		/*!	
			Getting the maximum acceptable value.
			\return Value (double type).
 		*/        
      double MaxValue(){
         return(m_ib.MaxValue());
      }   
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/ 
      void SetWidth(int aValue){
         m_Width=aValue;
         m_ib.SetWidth(m_Width-12);
      }  
		/*!	
			Getting the width.
			\return  Value (int type).
			\remark  Text box value only without the caption width.
 		*/        
      int Width(){
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/       
      int Height(){
         return(m_Height);
      }   
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/       
      int Top(){
         return(m_Top);
      }
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/         
      void Refresh(){
         if(m_Visible){
            Delete();
            m_d.Hide();            
            m_ib.Hide();
            Show();
         }
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         m_ib.SetPos(m_Left,m_Top);
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
         m_ib.SetPosLeft(m_Left);
      }  
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/   
      void SetPosTop(int aTop){
         m_Top=aTop;
         m_ib.SetPosTop(m_Top);
      }
		/*!	
			Enabling visibility.
 		*/         
      void Show(){
         m_Visible=true;
         Create();
         m_ib.Show();
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/       
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      }
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/        
      void Hide(){
         m_Visible=false;
         Delete();
         m_d.Hide();            
         m_ib.Hide();
      }
		/*!	
			Getting the value.
			\return Value (double type).
 		*/ 
      double Value(){
         return(m_ib.ValueDouble());
      }
		/*!	
			Setting the value. 
         param		double aValue - value.
 		*/        
      void SetValue(double aValue){
         m_ib.SetValue(aValue);
      }
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – new value entered.
 		*/        
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_event=0;
            if(sparam==""){
               if(id==CHARTEVENT_CLICK){
                  m_cc++;
                     if(m_cc>=2){
                        if(m_d.Visible()){
                           m_d.Hide();
                        }
                     }
               }                  
            }
            else{
               m_cc=0;
                  if(m_ib.Event(id,lparam,dparam,sparam)==1){
                     m_event=1;
                  }
               int m_dev=m_d.Event(id,lparam,dparam,sparam);
                  if(m_dev==1){
                     double m_oldvalue=m_ib.ValueDouble();
                     m_ib.SetValue(m_d.Value());
                        if(m_oldvalue!=m_d.Value()){
                           m_event=1;
                        }
                     ChartRedraw();
                  }
                  if(id==CHARTEVENT_OBJECT_CLICK){
                     if(sparam==m_BName){
                        if(m_d.Visible()){
                           m_d.Hide();
                        }  
                        else{
                           int m_w=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,m_SubWindow)/2;
                           int m_h=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,m_SubWindow)/2;
                           int m_x=m_Left+m_Width/2;
                           int m_y=m_Top+m_Height/2;
                           int m_cx;
                           int m_cy;
                              if(m_x<m_w){
                                 m_cx=m_Left;
                              }
                              else{
                                 m_cx=m_Left-m_d.Width()+m_Width;
                              }
                              if(m_y<m_h){
                                 m_cy=m_Top+m_ib.Height()-1;
                              }
                              else{
                                 m_cy=m_Top-m_d.Height()+1;
                              }                           
                           m_d.Show(m_cx,m_cy);
                        }                      
                     }
                     else{
                        if(m_dev!=2){
                           if(m_d.Visible()){
                              m_d.Hide();
                           } 
                        }
                     }
                  }
            }
         return(m_event);
      }
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/        
      void SetTag(string aTag){
         m_Tag=aTag;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/       
      string Tag(){
         return(m_Tag);
      } 
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/          
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               m_ib.SetSubWindow(m_SubWindow);
               m_d.SetSubWindow(m_SubWindow);               
               Refresh();
            }
      }  
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/               
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }  
		/*!	
			Getting the warning mode.
			\return bool type. True/false - warning/normal.
 		*/          
      bool Warning(){
         return(m_ib.Warning());
      }     
		/*!	
			Enabling/disabling the warning color.
			\param bool aValue - true/false (warning/normal). 
 		*/                    
      void SetWarning(bool aValue){
         m_ib.SetWarning(aValue);
      }
};

//+------------------------------------------------------------------+
//|         CTable Class                                            |
//+------------------------------------------------------------------+

/*!
   \brief   Graphical control "Table".
   \details It is possible to separately change height of each row
            and width of each column, manage the properties of every cell: background 
            and text color, font size and type. Several cells can be merged
            into one both horizontally and vertically. There is a method for exporting
            a table in HTML. Work in subwindows is supported. 
   \remark	This control consists of two scrollbars (vertical and
            horizontal) and text boxes. In order to get scrollbar names, 
            "_VSB" (vertical) and "_HSB" (horizontal) are added to aName. 
            In order to get text box (cell) names, "_Cell_R([R])_C([C])" is added, 
            where R is the row index, C is the column index.
*/
class CTable{
   private:
      struct sRow{
         int RowHeight;
         string CellText[];
         color CellBGColor[];
         color CellTxtColor[];
         string CellFont[];
         int CellFontSize[];
         int CellCollSpan[];
         int CellRowSpan[];
         int CellExist[];
         int CellMergeWidth[];
         int CellMergeHeight[];
      };
      sRow m_row[];
      CVScrollBar m__vsb;
      CHScrollBar m__hsb;
      string m_Name;
      int m_CollsCount;    // number of columns
      int m_CollWidth[];   // width of columns
      int m_RowsCount;     // number of rows
      int m_Width;         // width in pixels
      int m_Height;        // height in pixels
      int m_left;          // left indentation
      int m_Top;           // right indentation
      bool m_Visible;      // visibility flag
      int m_tWidth;        // calculated width
      int m_tHeight;       // calculated height
      bool m_vsb;          // visibility flag 
      bool m_hsb;
      color m_DefBgColor;
      color m_DefTxColor;
      string m_DefFontFace;
      int m_DefFontSize;
      int m_SubWindow;
      int m_mrc;
      int m_mcc;
      color m_FlashColor;
      int m_PreSelectedR;
      int m_PreSelectedC;
      bool m_PreNorm;
      string m_Tag;
      int m_LastClickedRow;
      int m_LastClickedColl;
      bool m_AllowSelection;
      void SB(){
         CountTWidth();
         CountTHeight();
         m_hsb=false;
         m_vsb=false;
         int m_bheight=m_Height;
         int m_bwidth=m_Width;
         int m_tth=m_tHeight;
         int m_ttw=m_tWidth;
            if(m_tWidth>m_bwidth){
               m_tWidth=m_bwidth;
               m_hsb=true;
               m_bheight-=m__hsb.Height();
            }
            if(m_tHeight>m_bheight){
               m_tHeight=m_bheight;
               m_vsb=true;
               m_bwidth-=m__vsb.Width();
            }
            if(m_tWidth>m_bwidth){
               m_tWidth=m_bwidth;
                  if(!m_hsb){
                     m_hsb=true;
                     m_bheight-=m__hsb.Height();
                  }
            }
            if(m_tHeight>m_bheight){
               m_tHeight=m_bheight;
                  if(!m_vsb){
                     m_vsb=true;
                     m_bwidth-=m__vsb.Width();
                 }
            }
            if(m_vsb){
               m__vsb.SetMax(m_tth-m_bheight);
               m__vsb.SetSmallChange((int)MathMax(MathMin(25,m_bheight),1));
               m__vsb.SetLageChange((int)MathMax(m_bheight,1));
            }
            else{
               m__vsb.SetValue(0);
            }
            if(m_hsb){
               m__hsb.SetMax(m_ttw-m_bwidth);
               m__hsb.SetSmallChange((int)MathMax(MathMin(25,m_bwidth),1));
               m__hsb.SetLageChange((int)MathMax(m_bwidth,1));
            }
            else{
               m__hsb.SetValue(0);
            }
      }     
      void CountTWidth(){
         m_tWidth=0;
            for(int i=0;i<m_CollsCount;i++){
               m_tWidth+=m_CollWidth[i];
            }
      }
      void CountTHeight(){
         m_tHeight=0;
            for(int i=0;i<m_RowsCount;i++){
               m_tHeight+=m_row[i].RowHeight;
            }          
      }
      string iif(bool aBool,string aIfTrue,string aIfFalse){
            if(aBool){
               return(aIfTrue);
            }
         return(aIfFalse);
      }
      string its(int aValue){
         return(IntegerToString(aValue));
      }
      void GetRGB(color aColor,int & aR,int & aG, int & aB){
         aR=aColor;
         aB=aR/65536;
         aR-=aB*65536;
         aG=aR/256;
         aR-=aG*256;
      }   
      string WEBColor(color aColor){
         int ttr=0,ttg=0,ttb=0;   
         GetRGB(aColor,ttr,ttg,ttb);
         return("#"+StringFormat("%02x",ttr)+StringFormat("%02x",ttg)+StringFormat("%02x",ttb));
      }    
      void Create(){
         m_PreSelectedR=-1;
         m_PreSelectedC=-1;   
         m_PreNorm=false;      
         SB();         
         m_mrc=MathMax(m_mrc,m_RowsCount);   
         m_mcc=MathMax(m_mcc,m_CollsCount);       
         int m_xpos=0;
         int m_ypos=0;
            if(m_vsb){
               m__vsb.SetHeight(m_tHeight);
               m__vsb.Show(m_left+m_tWidth,m_Top);
            }  
            else{
               m__vsb.Hide();
            }          
            if(m_hsb){
               m__hsb.SetWidth(m_tWidth);
               m__hsb.Show(m_left,m_Top+m_tHeight);
            }         
            else{
               m__hsb.Hide();
            }          
         int m_xs=m__hsb.Value();
         int m_ys=m__vsb.Value();
         m_ypos=-m_ys;
            for(int i=0;i<m_RowsCount;i++){
               m_xpos=-m_xs;
               bool m_br=false;
                  for(int j=0;j<m_CollsCount;j++){
                        if(m_row[i].CellExist[j]){
                           int m_w=m_CollWidth[j];
                           int m_h=m_row[i].RowHeight;
                              if(m_row[i].CellCollSpan[j]>1 || m_row[i].CellRowSpan[j]>1){
                                 if(m_row[i].CellCollSpan[j]>1){
                                    for(int k=j+1;k<m_CollsCount;k++){
                                          if(m_row[i].CellExist[k]){
                                             break;
                                          }
                                       m_w+=m_CollWidth[k];
                                    }
                                 }
                                 if(m_row[i].CellRowSpan[j]>1){
                                    for(int k=i+1;k<m_RowsCount;k++){
                                          if(m_row[k].CellExist[j]){
                                             break;
                                          }
                                       m_h+=m_row[k].RowHeight;
                                    } 
                                 }
                              }
                              if(m_xpos>m_tWidth){
                                    for(;j<m_CollsCount;j++){
                                       ObjectDelete(0,m_Name+"_Cell_R("+IntegerToString(i)+")_C("+IntegerToString(j)+")");
                                    }                              
                                 break;
                              }
                              if(m_ypos>m_tHeight){
                                    for(;j<m_CollsCount;j++){
                                       ObjectDelete(0,m_Name+"_Cell_R("+IntegerToString(i)+")_C("+IntegerToString(j)+")");
                                    }
                                 break;
                              }
                              if(m_left+m_xpos+m_w>m_left+m_tWidth){
                                 m_w=m_tWidth-m_xpos;
                                 m_br=true;
                              }
                              
                              if(m_ypos+m_h>m_tHeight){
                                 m_h=m_tHeight-m_ypos;
                              }
                           int m_l2=m_left+m_xpos;
                           int m_t2=m_Top+m_ypos;
                              if(m_xpos+m_w>0 && m_ypos+m_h>0){
                                    if(m_xpos<0){
                                       m_l2=m_left;
                                       m_w=m_xpos+m_w;
                                    }
                                    if(m_ypos<0){
                                       m_t2=m_Top;
                                       m_h=m_ypos+m_h;
                                    }
                                 w.Edit(m_Name+"_Cell_R("+IntegerToString(i)+")_C("+IntegerToString(j)+")",m_SubWindow,m_l2,m_t2,m_w,m_h,m_row[i].CellText[j],m_row[i].CellBGColor[j],m_row[i].CellTxtColor[j],m_row[i].CellFontSize[j],m_row[i].CellFont[j]);
                                 g.SetReadOnly(m_Name+"_Cell_R("+IntegerToString(i)+")_C("+IntegerToString(j)+")",true);
                              }
                              else{
                                 ObjectDelete(0,m_Name+"_Cell_R("+IntegerToString(i)+")_C("+IntegerToString(j)+")");
                              }                              
                              if(m_br){
                                 j++;
                                    for(;j<m_CollsCount;j++){
                                       ObjectDelete(0,m_Name+"_Cell_R("+IntegerToString(i)+")_C("+IntegerToString(j)+")");
                                    }
                                 break;
                              }
                        }
                     m_xpos+=m_CollWidth[j];                     
                  }
               m_ypos+=m_row[i].RowHeight;
            }
            
      }       
      void Delete(){
            for(int i=0;i<m_mrc;i++){
               for(int j=0;j<m_mcc;j++){
                  ObjectDelete(0,m_Name+"_Cell_R("+IntegerToString(i)+")_C("+IntegerToString(j)+")");
               }
            }  
         m_mrc=0;
         m_mcc=0;
      }  
      void SetCrossColor(int aR,int aC,bool aNormal){
         if(aNormal){
            for(int i=0;i<m_RowsCount;i++){
               string m_tn=m_Name+"_Cell_R("+IntegerToString(i)+")_C("+IntegerToString(aC)+")";
                  if(ObjectFind(0,m_tn)==m_SubWindow){
                     g.Attach(m_tn);
                     g.SetBgColor(m_row[i].CellBGColor[aC]);
                  }
            }
            for(int i=0;i<m_CollsCount;i++){
               string m_tn=m_Name+"_Cell_R("+IntegerToString(aR)+")_C("+IntegerToString(i)+")";
                  if(ObjectFind(0,m_tn)==m_SubWindow){
                     g.Attach(m_tn);
                     g.SetBgColor(m_row[aR].CellBGColor[i]);
                  }
            }  
         }
         else{
            for(int i=0;i<m_RowsCount;i++){
               string m_tn=m_Name+"_Cell_R("+IntegerToString(i)+")_C("+IntegerToString(aC)+")";
                  if(ObjectFind(0,m_tn)==m_SubWindow){
                     g.Attach(m_tn);
                     g.SetBgColor(m_FlashColor);
                  }
            }
            for(int i=0;i<m_CollsCount;i++){
               string m_tn=m_Name+"_Cell_R("+IntegerToString(aR)+")_C("+IntegerToString(i)+")";
                  if(ObjectFind(0,m_tn)==m_SubWindow){
                     g.Attach(m_tn);
                     g.SetBgColor(m_FlashColor);
                  }
            }           }
      }                       
   public:
		/*!	
			Control initialization.
            \param		string aName="CTable" - name,
            \param		int aWidth=200 - maximum width,
            \param		int aHeight=200 - maximum height.
            \remark     If the table exceeds the set size, scrollbars appear.
 		*/      
      void Init(string aName="CTable",int aWidth=200,int aHeight=200){
         m_SubWindow=0;
         m_Visible=false;
         m_Name=aName;
         m_CollsCount=0;
         m_RowsCount=0;         
         ArrayResize(m_CollWidth,0);
         ArrayResize(m_row,0);
         m_Width=aWidth;
         m_Height=aHeight;
         m_left=0;
         m_Top=0;
         m_tWidth=0;
         m_tHeight=0;  
         m_DefBgColor=ClrScheme.Color(0);
         m_DefTxColor=ClrScheme.Color(1);
         m_FlashColor=ClrScheme.Color(14);
         m_DefFontFace="Arial";
         m_DefFontSize=7;
         m_PreSelectedR=-1;
         m_PreSelectedC=-1;   
         m_PreNorm=true;      
         m_Tag="";
         m__vsb.Init(m_Name+"_VSB",m_Height);      
         m__hsb.Init(m_Name+"_HSB",m_Width);
         m_LastClickedRow=-1;
         m_LastClickedColl=-1;
         m_AllowSelection=true;
      }
		/*!	
			Adding a row.
			\remark Only the row array size is increased, properties of the new cells are set by default. If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void AddRow(){
         ArrayResize(m_row,m_RowsCount+1);
         ArrayResize(m_row[m_RowsCount].CellBGColor,m_CollsCount);
         ArrayResize(m_row[m_RowsCount].CellText,m_CollsCount);         
         ArrayResize(m_row[m_RowsCount].CellTxtColor,m_CollsCount);
         ArrayResize(m_row[m_RowsCount].CellFont,m_CollsCount);         
         ArrayResize(m_row[m_RowsCount].CellFontSize,m_CollsCount);   
         ArrayResize(m_row[m_RowsCount].CellCollSpan,m_CollsCount);         
         ArrayResize(m_row[m_RowsCount].CellRowSpan,m_CollsCount);  
         ArrayResize(m_row[m_RowsCount].CellExist,m_CollsCount);                
         m_row[m_RowsCount].RowHeight=15;
            for(int i=0;i<m_CollsCount;i++){
               m_row[m_RowsCount].CellBGColor[i]=m_DefBgColor;
               m_row[m_RowsCount].CellText[i]="";  
               m_row[m_RowsCount].CellTxtColor[i]=m_DefTxColor;
               m_row[m_RowsCount].CellFont[i]=m_DefFontFace;
               m_row[m_RowsCount].CellFontSize[i]=m_DefFontSize;
               m_row[m_RowsCount].CellCollSpan[i]=1;
               m_row[m_RowsCount].CellRowSpan[i]=1;
               m_row[m_RowsCount].CellExist[i]=true;
            }
         m_RowsCount++;
         CountTHeight();  
      }
		/*!	
			Deletion of a row with a specified index.
			\param   int aIndex - index of the row to be deleted
			\remark  If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void DeleteRow(int aIndex){
         if(m_RowsCount>0){
               for(int i=aIndex;i<m_RowsCount-1;i++){
                  ArrayResize(m_row[i].CellBGColor,ArraySize(m_row[i+1].CellBGColor));
                  ArrayCopy(m_row[i].CellBGColor,m_row[i+1].CellBGColor);
                  ArrayResize(m_row[i].CellCollSpan,ArraySize(m_row[i+1].CellCollSpan));
                  ArrayCopy(m_row[i].CellCollSpan,m_row[i+1].CellCollSpan);  
                  ArrayResize(m_row[i].CellExist,ArraySize(m_row[i+1].CellExist));
                  ArrayCopy(m_row[i].CellExist,m_row[i+1].CellExist);                 
                  ArrayResize(m_row[i].CellFont,ArraySize(m_row[i+1].CellFont));
                  ArrayCopy(m_row[i].CellFont,m_row[i+1].CellFont);  
                  ArrayResize(m_row[i].CellFontSize,ArraySize(m_row[i+1].CellFontSize));
                  ArrayCopy(m_row[i].CellFontSize,m_row[i+1].CellFontSize);  
                  ArrayResize(m_row[i].CellMergeHeight,ArraySize(m_row[i+1].CellMergeHeight));
                  ArrayCopy(m_row[i].CellMergeHeight,m_row[i+1].CellMergeHeight);  
                  ArrayResize(m_row[i].CellMergeWidth,ArraySize(m_row[i+1].CellMergeWidth));
                  ArrayCopy(m_row[i].CellMergeWidth,m_row[i+1].CellMergeWidth);  
                  ArrayResize(m_row[i].CellRowSpan,ArraySize(m_row[i+1].CellRowSpan));
                  ArrayCopy(m_row[i].CellRowSpan,m_row[i+1].CellRowSpan);  
                  ArrayResize(m_row[i].CellText,ArraySize(m_row[i+1].CellText));
                  ArrayCopy(m_row[i].CellText,m_row[i+1].CellText); 
                  ArrayResize(m_row[i].CellTxtColor,ArraySize(m_row[i+1].CellTxtColor));
                  ArrayCopy(m_row[i].CellTxtColor,m_row[i+1].CellTxtColor); 
                  m_row[i].RowHeight=m_row[i+1].RowHeight;
               }
            m_RowsCount--;
            ArrayResize(m_row,m_RowsCount);
         }    
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/ 
      void Show(int aLeft,int aTop){
         m_left=aLeft;
         m_Top=aTop;
         Show();
      }
		/*!	
			Enabling visibility.
 		*/        
      void Show(){
         m_Visible=true;
         Create();
         ChartRedraw();
      }  
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/             
      void Hide(){
         m_Visible=false;
         Delete();
            if(m__vsb.Visible() || m__hsb.Visible()){
               m__vsb.Hide();
               m__hsb.Hide();
            }
         ChartRedraw();
      }
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refresh(){
            if(m_Visible){
               Delete();
            }
            if(m__hsb.Visible()){
               m__hsb.Hide();
            }
            if(m__vsb.Visible()){
               m__vsb.Hide();
            }
            if(m_Visible){
               Show();
            }               
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetPos(int aLeft,int aTop){
         m_left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosLeft(int aLeft){
         m_left=aLeft;
      } 
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/            
      void SetPosTop(int aTop){
         m_Top=aTop;
      }     
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/ 
      int Left(){
         return(m_left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/         
      int Top(){
         return(m_Top);
      }
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/ 
      void SetWidth(int aWidth){
         m_Width=aWidth;
      }
		/*!	
			Setting the height.
            \param		int aWidth - height.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetHeight(int aHeight){
         m_Height=aHeight;
      }
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/         
      int Width(){
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/        
      int Height(){
         return(m_Height);
      }   
		/*!	
			Setting the number of table columns.
            \param		int aCount - number of columns.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/          
      void SetCollsCount(int aCount){
         int m_tmp=m_CollsCount;
         m_CollsCount=aCount;
         ArrayResize(m_CollWidth,m_CollsCount);
            for(int j=m_tmp;j<m_CollsCount;j++){
               m_CollWidth[j]=30;
            }
            for(int i=0;i<m_RowsCount;i++){
               ArrayResize(m_row[i].CellBGColor,m_CollsCount);
               ArrayResize(m_row[i].CellText,m_CollsCount);               
               ArrayResize(m_row[i].CellTxtColor,m_CollsCount);    
               ArrayResize(m_row[i].CellFont,m_CollsCount);               
               ArrayResize(m_row[i].CellFontSize,m_CollsCount); 
               ArrayResize(m_row[i].CellCollSpan,m_CollsCount);               
               ArrayResize(m_row[i].CellRowSpan,m_CollsCount);  
               ArrayResize(m_row[i].CellExist,m_CollsCount);                
                  for(int j=m_tmp;j<m_CollsCount;j++){
                     m_row[i].CellBGColor[j]=m_DefBgColor;
                     m_row[i].CellText[j]="";  
                     m_row[i].CellTxtColor[j]=m_DefTxColor;
                     m_row[i].CellFont[j]=m_DefFontFace;
                     m_row[i].CellFontSize[j]=m_DefFontSize;
                     m_row[i].CellCollSpan[j]=1;
                     m_row[i].CellRowSpan[j]=1;
                     m_row[i].CellExist[j]=true;
                  }
            }
         CountTWidth();
      }
		/*!	
			Setting the column width.
            \param		int aCollIndex - column index,
            \param		int aWidth - column width,            
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/       
      void SetCollWidth(int aCollIndex,int aWidth){
         m_CollWidth[aCollIndex]=aWidth;
         CountTWidth();
      }
		/*!	
			Setting the number of rows.
            \param		int aRowsCount - number of rows.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetRowsCount(int aRowsCount){
            if(aRowsCount<m_RowsCount){
               m_RowsCount=aRowsCount;
               ArrayResize(m_row,m_RowsCount); 
               CountTHeight();        
            }
            else{
               for(int i=m_RowsCount;i<aRowsCount;i++){
                  AddRow();
               }
            }
         
      }
		/*!	
			Clearing the table.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void Clear(){
         ArrayResize(m_row,0);
         ArrayResize(m_CollWidth,0);
         m_CollsCount=0;
         m_RowsCount=0;
         m__hsb.SetValue(0);
         m__vsb.SetValue(0);
      }
		/*!	
			Setting the row height.
            \param		int aRowIndex - row index,
            \param		int aHeight - row height,            
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetRowHeight(int aRowIndex,int aHeight){
         m_row[aRowIndex].RowHeight=aHeight;
         CountTHeight();
      }
		/*!	
			Setting the cell text.
            \param		int aRowIndex - row index,
            \param		int aCollIndex - column index,            
            \param		string aText - text.           
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetCellText(int aRowIndex,int aCollIndex,string aText){
         m_row[aRowIndex].CellText[aCollIndex]=aText;
      }
		/*!	
			Setting the cell background color.
            \param		int aRowIndex - row index,
            \param		int aCollIndex - column index,            
            \param		color aBGColor - background color.           
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/         
      void SetCellBGColor(int aRowIndex,int aCollIndex,color aBGColor){
         m_row[aRowIndex].CellBGColor[aCollIndex]=aBGColor;
      }
		/*!	
			Setting the cell text color.
            \param		int aRowIndex - row index,
            \param		int aCollIndex - column index,            
            \param		color aTxtColor - text color.           
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetCellTxtColor(int aRowIndex,int aCollIndex,color aTxtColor){
         m_row[aRowIndex].CellTxtColor[aCollIndex]=aTxtColor;
      }
		/*!	
			Setting the cell font.
            \param		int aRowIndex - row index,
            \param		int aCollIndex - column index,            
            \param		string aFont - font type.           
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetCellFont(int aRowIndex,int aCollIndex,string aFont="Arial"){
         m_row[aRowIndex].CellFont[aCollIndex]=aFont;
      }
		/*!	
			Setting the cell font size.
            \param		int aRowIndex - row index,
            \param		int aCollIndex - column index,            
            \param		aFontSize - font size.           
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/         
      void SetCellFontSize(int aRowIndex,int aCollIndex,int aFontSize){
         m_row[aRowIndex].CellFontSize[aCollIndex]=aFontSize;
      }
		/*!	
			Merging cells.
            \param		int aRowIndex - row index,
            \param		int aCollIndex - column index,            
            \param		int aRowSpan - number of cells vertically,
            \param		int aCollSpan - number of cells horizontally.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required. aRowSpan and aCollSpan value equal to 1 means that there is no merging of cells.
 		*/       
      void SetCellsMerge(int aRowIndex,int aCollIndex,int aRowSpan,int aCollSpan){
         aRowSpan=(int)MathMax(aRowSpan,1);
         aCollSpan=(int)MathMax(aCollSpan,1);
         if(m_row[aRowIndex].CellExist[aCollIndex]){
            int m_rs=m_row[aRowIndex].CellRowSpan[aCollIndex];
            int m_cs=m_row[aRowIndex].CellCollSpan[aCollIndex];
               for(int i=aRowIndex;i<MathMin(m_RowsCount,aRowIndex+m_rs);i++){
                  for(int j=aCollIndex;j<MathMin(m_CollsCount,aCollIndex+m_cs);j++){
                     m_row[i].CellExist[j]=true;
                  }
               }
            m_rs=aRowSpan;
            m_cs=aCollSpan;    
               for(int i=aRowIndex;i<MathMin(m_RowsCount,aRowIndex+m_rs);i++){
                  for(int j=aCollIndex;j<MathMin(m_CollsCount,aCollIndex+m_cs);j++){
                     m_row[i].CellExist[j]=false;
                  }
               }
            m_row[aRowIndex].CellRowSpan[aCollIndex]=aRowSpan;
            m_cs=m_row[aRowIndex].CellCollSpan[aCollIndex]=aCollSpan;   
            m_row[aRowIndex].CellExist[aCollIndex]=true;
         }
      }
		/*!	
			Number of columns.
			\return  Value (int type).
 		*/       
      int CollsCount(){
         return(m_CollsCount);
      }    
		/*!	
			Column width.
			\param	int aCollIndex - column index.
			\return  Value (int type).
 		*/         
      int CollWidth(int aCollIndex){
         return(m_CollWidth[aCollIndex]);
      }  
		/*!	
			Number of rows.
			\return  Value (int type).
 		*/         
      int RowsCount(){
         return(m_RowsCount);
      }  
		/*!	
			Row height.
			\param	int aRowIndex - row index.
			\return  Value (int type).
 		*/        
      int RowHeight(int aRowIndex){
         return(m_row[aRowIndex].RowHeight);
      }
		/*!	
			Cell text.
			\param	int aRowIndex - row index,
			\param	int aCollIndex - column index.			
			\return  Value (string type).
 		*/       
      string CellText(int aRowIndex,int aCollIndex){
         return(m_row[aRowIndex].CellText[aCollIndex]);
      }
		/*!	
			Cell background color.
			\param	int aRowIndex - row index,
			\param	int aCollIndex - column index.			
			\return  Value (color type).
 		*/         
      color CellBGColor(int aRowIndex,int aCollIndex){
         return(m_row[aRowIndex].CellBGColor[aCollIndex]);
      }
		/*!	
			Cell text color.
			\param	int aRowIndex - row index,
			\param	int aCollIndex - column index.			
			\return  Value (color type).
 		*/         
      color CellTxtColor(int aRowIndex,int aCollIndex){
         return(m_row[aRowIndex].CellTxtColor[aCollIndex]);
      }
		/*!	
			Cell font.
			\param	int aRowIndex - row index,
			\param	int aCollIndex - column index.			
			\return  Font (string type).
 		*/                
      string CellFont(int aRowIndex,int aCollIndex){
         return(m_row[aRowIndex].CellFont[aCollIndex]);
      }
		/*!	
			Cell font size.
			\param	int aRowIndex - row index,
			\param	int aCollIndex - column index.			
			\return  Size (int type).
 		*/         
      int CellFontSize(int aRowIndex,int aCollIndex){
         return(m_row[aRowIndex].CellFontSize[aCollIndex]);
      } 
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of clicking the cell.
 		*/ 
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_rv=0;
               if(m__hsb.Event(id,lparam,dparam,sparam) || m__vsb.Event(id,lparam,dparam,sparam)){
                  Show();
               }
               if(id==CHARTEVENT_OBJECT_CLICK){
                  if(StringFind(sparam,m_Name+"_Cell",0)==0){
                     int m_p1=StringFind(sparam,"R(",0)+2;
                     int m_p2=StringFind(sparam,")",0);
                     m_LastClickedRow=(int)StringToInteger(StringSubstr(sparam,m_p1,m_p2-m_p1));
                     m_p1=StringFind(sparam,"C(",0)+2;
                     m_p2=StringFind(sparam,")",0);
                     m_LastClickedColl=(int)StringToInteger(StringSubstr(sparam,m_p1,m_p2-m_p1));
                     m_rv=1;
                     //string m_tn=m_Name+"_Cell_R("+IntegerToString(m_LastClickedRow)+")_C("+IntegerToString(m_LastClickedColl)+")";
                        if(m_AllowSelection){
                              if(m_LastClickedRow==m_PreSelectedR && m_LastClickedColl==m_PreSelectedC){
                                 if(!m_PreNorm){
                                    SetCrossColor(m_PreSelectedR,m_PreSelectedC,true);
                                    m_PreNorm=true;
                                 } 
                                 else{
                                    SetCrossColor(m_PreSelectedR,m_PreSelectedC,false);
                                    m_PreNorm=false;                           
                                 }
                              }
                              else{
                                    if(m_PreSelectedR!=-1){
                                       SetCrossColor(m_PreSelectedR,m_PreSelectedC,true); 
                                    }                              
                                 SetCrossColor(m_LastClickedRow,m_LastClickedColl,false); 
                                 m_PreNorm=false;
                              }
                           m_PreSelectedR=m_LastClickedRow;
                           m_PreSelectedC=m_LastClickedColl;
                        }
                     ChartRedraw(0);
                  }
               }
         return(m_rv);
      }     
		/*!	
			Export in HTML.
			\return  HTML code (string type).
 		*/       
      string HTML(){
         string m_ms="style=\""+
            "border: 1px solid "+WEBColor(m_DefTxColor)+";"+
            "border-spacing: 0;"+
                                 "font-family: "+m_DefFontFace+";"+
                                 "font-size: "+its(m_DefFontSize)+"pt;"+
                                 "color: "+WEBColor(m_DefTxColor)+";"+    
                                 "background-color: "+WEBColor(m_DefBgColor)+";"+                             
            "\"";
         string m_str="<table "+m_ms+" cellspacing=0>\n";
            for(int i=0;i<ArraySize(m_row);i++){
               m_str=m_str+"<tr>\n";
                  for(int j=0;j<m_CollsCount;j++){
                     if(m_row[i].CellExist[j]){
                        string m_t1=iif(m_row[i].CellCollSpan[j]>1," colspan="+IntegerToString(m_row[i].CellCollSpan[j]),"");
                        string m_t2=iif(m_row[i].CellRowSpan[j]>1," rowspan="+IntegerToString(m_row[i].CellRowSpan[j]),"");
                        string m_t3="style=\"";
                           m_t3=m_t3+"border: 1px solid "+WEBColor(m_row[i].CellTxtColor[j])+";";
                           if(m_row[i].CellBGColor[j]!=m_DefBgColor)m_t3=m_t3+"background-color: "+WEBColor(m_row[i].CellBGColor[j])+";";
                           if(m_row[i].CellFont[j]!=m_DefFontFace)m_t3=m_t3+"font-family: "+m_row[i].CellFont[j]+";";
                           if(m_row[i].CellFontSize[j]!=m_DefFontSize)m_t3=m_t3+"font-size: "+its(m_row[i].CellFontSize[j])+"pt;";
                           if(m_row[i].CellTxtColor[j]!=m_DefTxColor)m_t3=m_t3+"color: "+WEBColor(m_row[i].CellTxtColor[j])+";";
                        m_t3=m_t3+"\"";
                        int m_w=0;
                           for(int k=j;k<j+m_row[i].CellCollSpan[j];k++){
                              if(k<m_CollsCount){
                                 m_w+=m_CollWidth[j];
                              }
                           }
                        int m_h=0;
                           for(int k=i;k<i+m_row[i].CellRowSpan[j];k++){
                              if(k<ArraySize(m_row)){
                                 m_h+=m_row[k].RowHeight;
                              }
                           } 
                        m_h-=2;
                        m_str=m_str+"<td "+m_t3+" width="+its(m_w)+" height="+its(m_h)+m_t1+m_t2+">"+ m_row[i].CellText[j]+"</td>\n";
                     }
                  }
               m_str=m_str+"</tr>\n";            
            }
         m_str=m_str+"</table>\n";     
         return(m_str);
      }   
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/         
      void SetTag(string aTag){
         m_Tag=aTag;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/     
      string Tag(){
         return(m_Tag);
      } 
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/         
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               m__hsb.SetSubWindow(m_SubWindow);
               m__vsb.SetSubWindow(m_SubWindow);               
               Refresh();
            }
      } 
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/                
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }   
		/*!	
			Index of the row of the last event.
			\return Value (int type).
 		*/        
      int LastClickedRaw(){
         return(m_LastClickedRow);
      }
		/*!	
			Index of the column of the last event.
			\return Value (int type).
 		*/    
      int LastClickedColl(){
         return(m_LastClickedColl);
      }
		/*!	
			Enabling the crosshair function.
			\param bool aValue - true/false - enabled/disabled.
 		*/       
      void SetAllowSelection(bool aValue){
         m_AllowSelection=aValue;
      }
		/*!	
			Checking whether the crosshair function is enabled.
			\return bool type. True - enabled, false - disabled.
 		*/        
      bool AllowSelection(){
         return(m_AllowSelection);
      }      
};

//+------------------------------------------------------------------+
//|         CFrame Class                                             |
//+------------------------------------------------------------------+

/*!
   \brief   Frame with a caption.
   \details Identical to the Frame method of CWorkPiece class but in the form of a class.
*/

class CFrame{
   private:
      int m_Left;
      int m_Top;
      int m_Width;
      int m_Height;
      int m_CaptionWidth;
      string m_Name;
      string m_Caption;
      int m_SubWindow;
      bool m_Visible;
      color m_BgColor;
      color m_BorderColor;
      color m_CaptionColor;
      string m_Tag;
   public:
		/*!	
			Control initialization.
            \param		string aName="CFrame" - name,
            \param		int aWidth=50 - width,
            \param		int aHeight=50 - height,
            \param		string aCaption="CFrame" - caption,
            \param		int aCaptionWidth=35 - caption width.
 		*/     
      void Init(string aName="CFrame",int aWidth=50,int aHeight=50,string aCaption="CFrame",int aCaptionWidth=37){
         m_Left=0;
         m_Top=0;
         m_Width=aWidth;
         m_Height=aHeight;
         m_CaptionWidth=aCaptionWidth;
         m_Name=aName;
         m_Caption=aCaption;
         m_SubWindow=0;
         m_Visible=false;
         m_BgColor=ClrScheme.Color(39);
         m_BorderColor=ClrScheme.Color(40);
         m_CaptionColor=ClrScheme.Color(41);     
         m_Tag="";    
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/   
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/             
      void SetPosTop(int aTop){
         m_Top=aTop;
      }      
		/*!	
			Enabling visibility.
 		*/       
      void Show(){
         m_Visible=true;
         w.Frame(m_Name,m_SubWindow,m_Left,m_Top,m_Width,m_Height,m_Caption,m_CaptionWidth,m_BgColor,m_BorderColor,m_CaptionColor);
         w.Redraw();
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/        
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      }   
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/   
      void Hide(){
         m_Visible=false;
         w.FrameDelete(m_Name);
         w.Redraw();
      }   
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refresh(){
         if(m_Visible){
            w.FrameDelete(m_Name);
            Show();
         }
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){ // Getting the X-coordinate
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/        
      int Top(){ // Getting the Y-coordinate
         return(m_Top);
      }
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/        
      int Width(){ // Getting the width
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/        
      int Height(){
         return(m_Height); // Getting the height
      }      
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/         
      void SetWidth(int aWidth){ // Setting the width 
         m_Width=aWidth;
      }
		/*!	
			Setting the height.
            \param		int aHeight - height.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/         
      void SetHeight(int aHeight){ // Setting the height 
         m_Height=aHeight;
      }
	
		/*!	
			Getting the caption width.
			\return  Value (int type).
 		*/        
      int CaptionWidth(){ // Getting the width
         return(m_CaptionWidth);
      }    
		/*!	
			Setting the caption width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/         
      void SetCaptionWidth(int aCaptionWidth){ // Setting the caption width
         m_CaptionWidth=aCaptionWidth;
      }   
		/*!	
			Getting the caption text.
			\return  Text (string type).
 		*/
      string Caption(){
         return(m_Caption);
      }    
		/*!	
			Setting the caption text.
            \param		string aCaption - caption text.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/ 
      void SetCaption(string aCaption){
         m_Caption=aCaption;
      }         
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/       
      void SetSubWindow(int aNumber){ // Defining the subwindow by the number
         int m_itmp=(int)MathMax(aNumber,0); // If the subwindow number is negative, 0 will be used - price chart
            if(m_itmp!=m_SubWindow){ // The specified number does not match the number where the control is located
               m_SubWindow=m_itmp; // New subwindow number registration
               Refresh(); // Recreating the graphical objects
            }
      }  
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/              
      void SetSubWindow(string aName){ // Defining the subwindow by the subwindow name
         SetSubWindow(ChartWindowFind(0,aName)); // Identifying the subwindow number by the name and defining the subwindow by the number
      }
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/       
      void SetTag(string aValue){ // Setting a tag
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/        
      string Tag(){ // Getting a tag
         return(m_Tag);
      }       
};


//+------------------------------------------------------------------+
//|         CButton Class                                             |
//+------------------------------------------------------------------+

/*!
   \brief   Button.
   \details Graphical object OBJ_BUTTON.
*/

class CButton{
   private:
      int m_Left;
      int m_Top;
      int m_Width;
      int m_Height;
      int m_CaptionWidth;
      string m_Name;
      string m_Caption;
      int m_SubWindow;
      bool m_Visible;
      color m_BgColor;
      color m_CaptionColor;
      string m_Tag;
   public:
		/*!	
			Control initialization.
            \param		string aName="CButtom" - name,
            \param		int aWidth=50 - width,
            \param		int aHeight=50 - height,
            \param		string aCaption="CButton" - caption,
 		*/     
      void Init(string aName="CButton",int aWidth=80,int aHeight=30,string aCaption="CButton"){
         m_Left=0;
         m_Top=0;
         m_Width=aWidth;
         m_Height=aHeight;
         m_Name=aName;
         m_Caption=aCaption;
         m_SubWindow=0;
         m_Visible=false;
         m_BgColor=ClrScheme.Color(42);
         m_CaptionColor=ClrScheme.Color(43);     
         m_Tag="";    
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/   
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/             
      void SetPosTop(int aTop){
         m_Top=aTop;
      }      
		/*!	
			Enabling visibility.
 		*/       
      void Show(){
         m_Visible=true;
         w.Button(m_Name,m_SubWindow,m_Left,m_Top,m_Width,m_Height,m_Caption,m_BgColor,m_CaptionColor);
         w.Redraw();
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/        
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      }   
		/*!	
			Hiding the control (graphical object deletion).
 		*/   
      void Hide(){
         m_Visible=false;
         w.Delete(m_Name);
         w.Redraw();
      }   
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refresh(){
         if(m_Visible){
            w.Delete(m_Name);
            Show();
         }
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){ // Getting the X-coordinate
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/        
      int Top(){ // Getting the Y-coordinate
         return(m_Top);
      }
		/*!	
			Getting the width.
			\return  Value (int type).
 		*/        
      int Width(){ // Getting the width
         return(m_Width);
      }
		/*!	
			Getting the height.
			\return  Value (int type).
 		*/        
      int Height(){
         return(m_Height); // Getting the height
      }      
		/*!	
			Setting the width.
            \param		int aWidth - width.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/         
      void SetWidth(int aWidth){ // Setting the width 
         m_Width=aWidth;
      }
		/*!	
			Setting the height.
            \param		int aHeight - height.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/         
      void SetHeight(int aHeight){ // Setting the height 
         m_Height=aHeight;
      }
		/*!	
			Getting the caption text.
			\return  Text (string type).
 		*/
      string Caption(){
         return(m_Caption);
      }    
		/*!	
			Setting the caption text.
            \param		string aCaption - caption text.
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/ 
      void SetCaption(string aCaption){
         m_Caption=aCaption;
      }         
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/       
      void SetSubWindow(int aNumber){ // Defining the subwindow by the number
         int m_itmp=(int)MathMax(aNumber,0); // If the subwindow number is negative, 0 will be used - price chart
            if(m_itmp!=m_SubWindow){ // The specified number does not match the number where the control is located
               m_SubWindow=m_itmp; // New subwindow number registration
               Refresh(); // Recreating the graphical objects
            }
      }  
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/              
      void SetSubWindow(string aName){ // Defining the subwindow by the subwindow name
         SetSubWindow(ChartWindowFind(0,aName)); // Identifying the subwindow number by the name and defining the subwindow by the number
      }
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/       
      void SetTag(string aValue){ // Setting a tag
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/        
      string Tag(){ // Getting a tag
         return(m_Tag);
      }
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – event of clicking the button.
 		*/ 
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
            if(id==CHARTEVENT_OBJECT_CLICK){
               if(sparam==m_Name){
                  if(g.State(m_Name)){
                     Sleep(100);
                     g.SetState(m_Name,false);
                     g.Redraw();
                     return(1);
                  }
               }
            }
         return(0);
      }
};


//+------------------------------------------------------------------+
//|         CLabel Class                                             |
//+------------------------------------------------------------------+

/*!
   \brief   Label.
   \details Graphical object OBJ_LABEL.
*/

class CLabel{
   private:
      int m_Left;
      int m_Top;
      int m_Width;
      int m_Height;
      string m_Name;
      string m_Text;
      string m_TextArray[];
      int m_SubWindow;
      bool m_Visible;
      color m_Color;
      int m_FontSize;
      string m_Font;
      string m_Tag;
      void Create(){
         for(int i=0;i<ArraySize(m_TextArray);i++){
            w.Label(m_Name+"_Lbl("+IntegerToString(i)+")",m_SubWindow,m_Left,m_Top+int(i*m_FontSize*1.4),m_TextArray[i],m_Color,m_FontSize,m_Font);
         }      
      }
      void Delete(){
         for(int i=0;i<ArraySize(m_TextArray);i++){
            g.Delete(m_Name+"_Lbl("+IntegerToString(i)+")");
         }
      }
   public:
		/*!	
			Control initialization.
            \param		string aName="CLabel" - name,
            \param		string aText="CLabel" - caption,
 		*/     
      void Init(string aName="CLabel",string aText="CLabel"){
         m_Left=0;
         m_Top=0;
         m_Name=aName;
         m_Text=aText;
         m_SubWindow=0;
         m_Visible=false;
         m_Color=ClrScheme.Color(44);
         m_FontSize=8;
         m_Font="Arial";         
         m_Tag="";  
         StringSplit(m_Text,'\n',m_TextArray);
         m_Visible=false;
      }
		/*!	
			Setting the X- and Y-coordinates.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/   
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting the X-coordinate.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }
		/*!	
			Setting the Y-coordinate.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/             
      void SetPosTop(int aTop){
         m_Top=aTop;
      }      
		/*!	
			Enabling visibility.
 		*/       
      void Show(){
         m_Visible=true;
         Create();
         ChartRedraw();
      }
		/*!	
			Enabling visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).			
 		*/        
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      }   
		/*!	
			Hiding the control (deletion of graphical objects).
 		*/   
      void Hide(){
         m_Visible=false;
         Delete();            
         ChartRedraw();
      }   
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/        
      void Refresh(){
         if(m_Visible){
            Delete();
            Show();
         }
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){ // Getting the X-coordinate
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/        
      int Top(){ // Getting the Y-coordinate
         return(m_Top);
      }
		/*!	
			Getting the caption text.
			\return  Text (string type).
 		*/
      string Text(){
         return(m_Text);
      }    
		/*!	
			Setting the caption text.
            \param		string aText="" - caption text.
 		*/ 
      void SetText(string aText=""){
            if(m_Visible){
               Delete();
            }
         m_Text=aText;
         StringSplit(m_Text,'\n',m_TextArray);
            if(m_Visible){
               Create();
               ChartRedraw();
            }
      }
		/*!	
			Getting the font.
			\return  Font (string type).
 		*/
      string Font(){
         return(m_Font);
      }    
		/*!	
			Setting the font.
            \param		string aFont="Arial" - font.
 		*/ 
      void SetFont(string aFont="Arial"){
         m_Font=aFont;
         Refresh();
      }
		/*!	
			Getting the font size.
			\return  Font size (int type).
 		*/
      int FontSize(){
         return(m_FontSize);
      }    
		/*!	
			Setting the font size.
            \param		string aFontSize=8 - font size.
 		*/ 
      void SetFontSize(int aFontSize=8){
         m_FontSize=aFontSize;
         Refresh();
      }     
		/*!	
			Setting the color.
            \param		color aColor=16777216 - color. This parameter is optional - if no value is set, a default color from the color scheme will be set. 
 		*/ 
      void SetColor(color aColor=16777216){
            if(aColor==16777216){
               aColor=ClrScheme.Color(44);
            }
         m_Color=aColor;
         Refresh();
      }          
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/       
      void SetSubWindow(int aNumber){ // Defining the subwindow by the number
         int m_itmp=(int)MathMax(aNumber,0); // If the subwindow number is negative, 0 will be used - price chart
            if(m_itmp!=m_SubWindow){ // The specified number does not match the number where the control is located
               m_SubWindow=m_itmp; // New subwindow number registration
               Refresh(); // Recreating the graphical objects
            }
      }  
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/              
      void SetSubWindow(string aName){ // Defining the subwindow by the subwindow name
         SetSubWindow(ChartWindowFind(0,aName)); // Identifying the subwindow number by the name and defining the subwindow by the number
      }
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/       
      void SetTag(string aValue){ // Setting a tag
         m_Tag=aValue;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/        
      string Tag(){ // Getting a tag
         return(m_Tag);
      }
};

//+------------------------------------------------------------------+
//|         CCalendar class                                          |
//+------------------------------------------------------------------+

/*!
   \brief   Графический элемент управления "Calendar" graphical control element.
   \details Several operation modes: entering date, entering time, entering date and time, 
            additional mode with the vertical line.
   \remark	The class is a an integral part of the CCalendarInput class.
*/

class CCalendar{
   protected:
      struct m_SCellInfo{
         int Year;
         int Month;
         int Day;
      };
      int m_SubWindow;
      int m_Left;
      int m_Top;
      string m_Name;
      bool m_Visible;
      CComBox m_cb;
      CSpinInputBox m_sb;
      CComBox m_cb1;
      CComBox m_cb2;
      CComBox m_cb3;
      datetime m_TimeValue;
      MqlDateTime m_TimeStr;
      color m_BgColor;
      color m_BorderColor;
      color m_ButBgColor;
      color m_ButTxtColor;  
      color m_TxtColor;
      color m_HeaderBgColor;
      color m_DayBgColor;
      color m_OtherMonthDayBgColor;
      color m_DayColor;
      color m_ToDayColor;
      color m_RdBgColor;
      datetime m_ToDay;
      MqlDateTime m_ToDayStr;
      m_SCellInfo m_Cell[7][6];
      bool m_Date;
      bool m_Time;
      bool m_Sec;
      bool m_Line;
      int m_TimeMode;
      string m_Tag;
      string m_NowText;
      string m_ToDayText;
      string m_LineText;
      string m_wdn[];
      string F2(int aA){
            if(aA<10){
               return("0"+IntegerToString(aA));
            }
         return(IntegerToString(aA));
      }
      datetime ModeTime(){
         if(m_TimeMode==1){
            return(TimeLocal());
         }
         else{
            return(TimeCurrent());         
         }
      }
      void Create(){
         w.Canvas(m_Name+"_Canvas",m_SubWindow,m_Left,m_Top,140,55,m_BgColor,m_BorderColor);
         int m_AddY=0;
            if(m_Date){
               m_AddY=117;
               w.Button(m_Name+"_Left",m_SubWindow,m_Left+3,m_Top+2,15,15,"<",m_ButBgColor,m_ButTxtColor);
               m_cb.Show(m_Left+20,m_Top+2);
               m_sb.Show(m_Left+81,m_Top+2);         
               w.Button(m_Name+"_Right",m_SubWindow,m_Left+122,m_Top+2,15,15,">",m_ButBgColor,m_ButTxtColor);
               
               string m_tn; 
                  for(int i=0;i<7;i++){
                     m_tn=m_Name+"_WDN_"+IntegerToString(i);
                     w.Edit(m_tn,m_SubWindow,m_Left+3+i*19,m_Top+18,20,13,m_wdn[i],m_HeaderBgColor,m_TxtColor);
                     g.SetReadOnly(m_tn,true);
                     
                  }
                  for(int j=0;j<6;j++){
                     for(int i=0;i<7;i++){
                        m_tn=m_Name+"_D_"+IntegerToString(i)+"_"+IntegerToString(j);
                        w.Edit(m_Name+"_D_"+IntegerToString(i)+"_"+IntegerToString(j),m_SubWindow,m_Left+3+i*19,m_Top+18+12+j*12,20,13,"zz",m_DayBgColor,m_TxtColor);
                        g.SetReadOnly(m_tn,true);
                     }
                  }  
                  
               m_ToDay=ModeTime();
               TimeToStruct(m_ToDay,m_ToDayStr);            
               w.Canvas(m_Name+"_CDM",m_SubWindow,m_Left+3,m_Top+104,20,12, m_BgColor,m_ToDayColor);
               w.Button(m_Name+"_CDMB",m_SubWindow,m_Left+4,m_Top+105,18,10," ",m_ButBgColor,m_ButTxtColor);
               w.Label(m_Name+"_CD",m_SubWindow,m_Left+29,m_Top+105,"",m_TxtColor,7);
               w.Canvas(m_Name+"_HL1",m_SubWindow,m_Left,m_Top+117,140,1,m_BorderColor,m_BorderColor);
               g.SetYSize(m_Name+"_Canvas",m_AddY+19);
            }
            
            if(m_Time){
               int m_xad=0;
               int m_xad1=0;
                  if(m_Sec){
                     m_cb3.Show(m_Left+90+3,m_Top+2+m_AddY);
                  }   
                  else{
                     m_xad=20;
                     m_xad1=5;
                  }         
               m_cb1.Show(m_Left+13+m_xad,m_Top+2+m_AddY);
               m_cb2.Show(m_Left+53+m_xad,m_Top+2+m_AddY);

               w.Canvas(m_Name+"_CTM",m_SubWindow,m_Left+3,m_Top+18+m_AddY,20,12, m_BgColor,m_ToDayColor);
               w.Button(m_Name+"_CTMB",m_SubWindow,m_Left+4,m_Top+19+m_AddY,18,10," ",m_ButBgColor,m_ButTxtColor);         
               w.Label(m_Name+"_CT",m_SubWindow,m_Left+33+m_xad1,m_Top+19+m_AddY,"",m_TxtColor,7);
               w.Canvas(m_Name+"_HL2",m_SubWindow,m_Left,m_Top+31+m_AddY,140,1,m_BorderColor,m_BorderColor);
               m_AddY+=31;
               g.SetYSize(m_Name+"_Canvas",m_AddY+19);
            }
            if(m_Line){
               w.Button(m_Name+"_Line",m_SubWindow,m_Left+50,m_Top+m_AddY+2,40,15,m_LineText,m_ButBgColor,m_ButTxtColor);
            }               
         w.Button(m_Name+"_Cancel",m_SubWindow,m_Left+3,m_Top+m_AddY+2,25,15," x",m_ButBgColor,m_ButTxtColor);
         w.Button(m_Name+"_Ok",m_SubWindow,m_Left+112,m_Top+m_AddY+2,25,15,"ok",m_ButBgColor,m_ButTxtColor);
         g.SetYSize(m_Name+"_Canvas",m_AddY+19);
      }
      void Delete(){
         ObjectDelete(0,m_Name+"_Canvas");
         ObjectDelete(0,m_Name+"_Left");
         ObjectDelete(0,m_Name+"_Right");
            for(int i=0;i<7;i++){
               ObjectDelete(0,m_Name+"_WDN_"+IntegerToString(i));
            }
            for(int j=0;j<6;j++){    
               for(int i=0;i<7;i++){
                  ObjectDelete(0,m_Name+"_D_"+IntegerToString(i)+"_"+IntegerToString(j));
               }
            }   
         ObjectDelete(0,m_Name+"_CDM");
         ObjectDelete(0,m_Name+"_CD");
         ObjectDelete(0,m_Name+"_CDMB");         
         ObjectDelete(0,m_Name+"_HL1");
         ObjectDelete(0,m_Name+"_CTM");
         ObjectDelete(0,m_Name+"_CT");
         ObjectDelete(0,m_Name+"_CTMB");         
         ObjectDelete(0,m_Name+"_HL2");
         ObjectDelete(0,m_Name+"_Cancel");         
         ObjectDelete(0,m_Name+"_Ok");  
         ObjectDelete(0,m_Name+"_Line");            
         ObjectDelete(0,m_Name+"_VLine");        
         m_cb.Hide();
         m_sb.Hide();
         m_cb1.Hide();
         m_cb2.Hide();
         m_cb3.Hide();
      }
      int MonthStartDayOfWeek(int aMonth,int aYear){
         string m_sdate=IntegerToString(aYear)+"."+IntegerToString(aMonth)+".1";
         datetime m_ddate=StringToTime(m_sdate);
         MqlDateTime m_tstr;
         TimeToStruct(m_ddate,m_tstr); 
         return(m_tstr.day_of_week);
      }
      int DaysInMonth(int aMonth,int aYear){
         int m_dim[]={0,31,28,31,30,31,30,31,31,30,31,30,31};
         int m_rv=m_dim[aMonth];
            if(aMonth==2 && aYear%4==1){
               m_rv++;
            }
         return(m_rv);   
      }
      void SetCalendar(){
         string m_tn;
         int i,j;
            for(j=0;j<6;j++){
               for(i=0;i<7;i++){
                  m_tn=m_Name+"_D_"+IntegerToString(i)+"_"+IntegerToString(j);
                  g.SetText(m_tn,"");
                  g.SetColor(m_tn,m_TxtColor);
               }
            }       
         int m_m=m_cb.SelectedIndex()+1;
         int m_y=(int)m_sb.Value();
         if(m_y<1970)return;
         int m_mswd=MonthStartDayOfWeek(m_m,m_y);
            if(m_mswd==1){ // Month starts from Monday
               j=1;
            }
            else{
               j=0;
            }
         i=m_mswd-1;
            if(i<0){
               i=6;
            }
         int m_NextDay;
         int m_pm=m_m;
         int m_py=m_y;
         m_pm--;
            if(m_pm<=0){
               m_pm=12;
               m_py--;
            }
         m_NextDay=DaysInMonth(m_pm,m_py);
         color m_bc=m_OtherMonthDayBgColor;
         int k=i-1;         
            if(k<0){
               k=6;
            }
            for(;k>=0;k--){
               m_tn=m_Name+"_D_"+IntegerToString(k)+"_"+IntegerToString(0);
               g.SetText(m_tn,IntegerToString(m_NextDay));
               m_Cell[k][0].Day=m_NextDay;
               m_Cell[k][0].Month=m_pm;
               m_Cell[k][0].Year=m_py;
               g.SetBgColor(m_tn,m_bc);
               m_NextDay--;
            }
         int m_ditm=DaysInMonth(m_m,m_y);
         m_bc=m_DayBgColor;
         m_NextDay=1;   
         bool m_NextMonth=false;      
            for(;j<6;j++){
                  for(;i<7;i++){
                     m_tn=m_Name+"_D_"+IntegerToString(i)+"_"+IntegerToString(j);
                     g.SetText(m_tn,IntegerToString(m_NextDay));
                     m_Cell[i][j].Day=m_NextDay;
                     m_Cell[i][j].Month=m_m+m_NextMonth;
                     m_Cell[i][j].Year=m_y;                     
                     g.SetBgColor(m_tn,m_bc);
                        if(m_NextDay==m_TimeStr.day){
                           if(!m_NextMonth){
                              g.SetBgColor(m_tn,m_DayColor);
                           }
                        }
                        if(m_NextDay==m_ditm){
                           m_NextMonth=true;
                           m_NextDay=0;
                           m_bc=m_OtherMonthDayBgColor;
                        }
                     m_NextDay++;
                  }
               i=0;
            }
            for(j=0;j<6;j++){
               for(i=0;i<7;i++){
                  if(m_Cell[i][j].Day==m_ToDayStr.day && m_Cell[i][j].Month==m_ToDayStr.mon && m_Cell[i][j].Year==m_ToDayStr.year){
                     m_tn=m_Name+"_D_"+IntegerToString(i)+"_"+IntegerToString(j);                 
                     g.Attach(m_tn);
                     color m_t1=g.BgColor();
                     int m_t3=g.XDistance();
                     int m_t4=g.YDistance();
                     string m_t5=g.Text();
                     int m_t6=g.XSize();
                     int m_t7=g.YSize();
                     g.Delete();
                     w.Edit(m_tn,m_SubWindow,m_t3,m_t4,m_t6,m_t7,m_t5,m_t1,m_ToDayColor);
                     g.SetReadOnly(m_tn,true);                     
                  }
               }
            }  
      }
      datetime SolveTime(int aY,int aM,int aD,int ah,int am, int as){
         MqlDateTime m_tstr;
         m_tstr.year=aY;
         m_tstr.mon=aM;
         m_tstr.day=aD;
         m_tstr.hour=ah;
         m_tstr.min=am;
         m_tstr.sec=as;
         return(StructToTime(m_tstr));
      }      
   public:
      /*!
         Initialization.
            string aName="CCalendar" - control element name,
            bool aDate=true - date entering is used,
            bool aTime=true - time entering is used,
            bool aSeconds=true - seconds are used,
            bool aLine=true - vertical line entering is used,
            int aTimeMode=0 - time mode (0 - terminal time, 2 - local time).
      */
      void Init(string aName="CCalendar",bool aDate=true,bool aTime=true,bool aSeconds=true,bool aLine=true,int aTimeMode=0){
         m_TimeMode=aTimeMode;
         m_Visible=false;
         m_Date=aDate;
         m_Time=aTime;
         m_Sec=aSeconds;
         m_Line=aLine;
         m_Name=aName;
         m_SubWindow=0;
         m_Left=0;
         m_Top=0;
         m_BgColor=ClrScheme.Color(45);               // Background color
         m_BorderColor=ClrScheme.Color(46);           // Frame color
         m_ButBgColor=ClrScheme.Color(47);            // Buttons color
         m_ButTxtColor=ClrScheme.Color(48);           // Buttons labels color   
         m_TxtColor=ClrScheme.Color(49);              // Labels color
         m_HeaderBgColor=ClrScheme.Color(50);
         m_DayBgColor=ClrScheme.Color(51);            // Calendar days color
         m_OtherMonthDayBgColor=ClrScheme.Color(52);  // Previous and next month days color
         m_DayColor=ClrScheme.Color(53);              // Selected day color  
         m_ToDayColor=ClrScheme.Color(54);            // Current day frame color   
         m_cb.Init(aName+"_Month",59,"");
         string m_Month[];
         //string m_Month[]={"January","February","March","April","May","June","July","August","September","October","November","December"};
            if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian"){
               StringSplit("Январь,Февраль,Maрт,Апрель,Май,Июнь,Июль,Август,Сентябрь,Октябрь,Ноябрь,Декабрь",',',m_Month);
               m_NowText="Сейчас";
               m_ToDayText="Сегодня";
               m_LineText="Линия";
               StringSplit("Пн,Вт,Ср,Чт,Пт,Сб,Вс",',',m_wdn);
            }       
            else{
              StringSplit("January,February,Mart,April,May,June,July,August,Septemb.,October,Novemb.,Decemb.",',',m_Month);
               m_NowText="Now";
               m_ToDayText="Today";            
               m_LineText="Line";
               StringSplit("Mo,Tu,We,Th,Fr,Sa,Su",',',m_wdn);
            }        
            for(int i=0;i<ArraySize(m_Month);i++){
               m_cb.AddItem(m_Month[i]);
            }               
         m_sb.Init(aName+"_Year",39,1,"");
         m_sb.SetReadOnly(false);
         m_sb.SetMinValue(1970);
         m_cb1.Init(aName+"_Hour",30,"Ч");
         m_cb2.Init(aName+"_Min",30,"М");
         m_cb3.Init(aName+"_Sec",30,"С");
         m_cb1.SetReadOnly(false);
         m_cb2.SetReadOnly(false);
         m_cb3.SetReadOnly(false);
            for(int i=0;i<24;i++){
               m_cb1.AddItem(F2(i));
            }
            for(int i=0;i<60;i++){
               m_cb2.AddItem(F2(i));
               m_cb3.AddItem(F2(i));
            }     
         SetValueDateTime(ModeTime());
         m_Tag="";
      }
      /*!
         "Today" and "Now" fields update.
      */
      void TimeNowRefresh(){
         if(m_Visible){
            m_ToDay=ModeTime();
            TimeToStruct(m_ToDay,m_ToDayStr);  
               if(m_Time){
                  int m_fl=TIME_MINUTES;
                     if(m_Sec){
                        m_fl=TIME_SECONDS; 
                     }
                  g.SetText(m_Name+"_CT",m_NowText+": "+TimeToString(m_ToDay,m_fl));
               }
               if(m_Date){
                  g.SetText(m_Name+"_CD",m_ToDayText+": "+TimeToString(m_ToDay,TIME_DATE));
               }
            g.Redraw();
         }
      }
      /*!
         Date-time setting.
         \param		int aTime - date-time.
      */
      void SetValueDateTime(datetime aTime){
         m_TimeValue=aTime;
         TimeToStruct(m_TimeValue,m_TimeStr);
            if(!m_Date){
               m_TimeStr.day=1;
               m_TimeStr.year=1970;
               m_TimeStr.mon=1;
               m_TimeValue=StructToTime(m_TimeStr);
            }
            if(!m_Time){
               m_TimeStr.hour=0;
               m_TimeStr.min=0;
               m_TimeStr.sec=0;
               m_TimeValue=StructToTime(m_TimeStr);
            }
            else{
               if(!m_Sec){
                  m_TimeStr.sec=0;
                  m_TimeValue=StructToTime(m_TimeStr); 
               }
            }
            if(m_cb.SelectedIndex()!=(m_TimeStr.mon-1)){
               m_cb.SetSelectedIndex((m_TimeStr.mon-1));
            }
            if(m_sb.Value()!=m_TimeStr.year){
               m_sb.SetValue(m_TimeStr.year);
            }    
            if(m_cb1.SelectedIndex()!=m_TimeStr.hour){ 
               m_cb1.SetSelectedIndex(m_TimeStr.hour);
            }      
            if(m_cb2.SelectedIndex()!=m_TimeStr.min){ 
               m_cb2.SetSelectedIndex(m_TimeStr.min);
            }  
            if(m_cb3.SelectedIndex()!=m_TimeStr.sec){ 
               m_cb3.SetSelectedIndex(m_TimeStr.sec);
            }                                    
            if(m_Visible){
               SetCalendar();
               ChartRedraw(0);
            }
      }
      /*!
         Getting numerical date-time value.
         \return  Value (datetime type).
      */
      datetime DateTimeValue(){
         return(m_TimeValue);
      }
      
      /*!
         Getting the date-time string.
         \return  Text (string type).
      */
      string DateTimeString(){
         string m_ret="";
            if(m_Date){
               if(m_Time){
                  m_ret=TimeToString(m_TimeValue,TIME_DATE)+" ";
                     if(m_Sec){
                        m_ret+=TimeToString(m_TimeValue,TIME_SECONDS);
                     }
                     else{
                        m_ret+=TimeToString(m_TimeValue,TIME_MINUTES);
                     }
               }
               else{
                  m_ret=TimeToString(m_TimeValue,TIME_DATE);
               }
            }
            else{
               if(m_Time){
                  if(m_Sec){
                     m_ret=TimeToString(m_TimeValue,TIME_SECONDS);
                  }
                  else{
                     m_ret=TimeToString(m_TimeValue,TIME_MINUTES);
                  }
               }
               else{
                  m_ret="";
               }
            }
         return(m_ret);
      }      
		/*!	
			Setting X and Y coordinates.
            \param		int aLeft - X coordinate (the distance from the chart's left margin),
            \param		int aTop - Y coordinate (the distance from the chart's upper margin).
            \remark	   In case the control element is displayed, update using Refresh() method is required.
 		*/     
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
      }
		/*!	
			Setting X coordinate.
            \param		int aLeft - X coordinate (the distance from the chart's left margin).
            \remark	   In case the control element is displayed, update using Refresh() method is required.
 		*/   
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
      }      
		/*!	
			Setting Y coordinate.
            \param		int aTop - Y coordinate (the distance from the chart's upper margin).
            \remark	   In case the control element is displayed, update using Refresh() method is required.
 		*/  
      void SetPosTop(int aTop){
         m_Top=aTop;
      }      
		/*!	
			Getting X coordinate.
			\return  Value (int type).
 		*/    
      int Left(int aLeft){
         return(m_Left);
      }      
		/*!	
			Getting Y coordinate.
			\return  Value (int type).
 		*/      
      int Top(int aTop){
         return(m_Top);
      }  
		/*!	
			Getting width.
			\return  Value (int type).
			\remark  Only the value of the text field without consideration of the label width.
 		*/        
      int Width(){
         return(140);
      }
		/*!	
			Getting height.
			\return  Value (int type).
 		*/       
      int Height(){
         int m_rv=0;
            if(m_Date){
               m_rv=117;
            }
            if(m_Time){
               m_rv+=31;
            }
         m_rv+=19;
         return(m_rv);
      }
		/*!	
			Enabling visibility.
 		*/    
      void Show(){
         m_Visible=true;
         Create();
         SetCalendar();
         TimeNowRefresh();
      }
		/*!	
			Enabling visibility on a specified position.
         \param		int aLeft - X coordinate (the distance from the chart's left margin),
         \param		int aTop - Y coordinate (the distance from the chart's upper margin).			
 		*/         
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      }      
		/*!	
			Hiding control element (graphical objects removal).
 		*/   
      void Hide(){
         m_Visible=false;
         Delete();
         ChartRedraw();
      }
		/*!	
			Updating (hiding and display with new parameters).
 		*/        
      void Refresh(){
         if(m_Visible){
            Delete();
            Show();
         }
      }
      /*!
			Events processing method.
			\remark  The method is called from the OnChartEvent() function, all parameters correspond to the OnChartEvent() function parameters.
			\return  0 - no event, 1 - "ok" button has been hit.
      */   
      int Event(const int id,const long &lparam,const double &dparam,const string &sparam){
         datetime m_NewTime;
         bool m_lineoff=false;
            if(m_cb1.Event(id,lparam,dparam,sparam)==1){
               m_cb1.SetSelectedIndex((int)MathMax(0,(int)MathMin(StringToInteger(m_cb1.Value()),23)));
               m_NewTime=SolveTime(m_TimeStr.year,m_TimeStr.mon,m_TimeStr.day,m_cb1.SelectedIndex(),m_TimeStr.min,m_TimeStr.sec);
               SetValueDateTime(m_NewTime);
               m_lineoff=true;
            }
            if(m_cb2.Event(id,lparam,dparam,sparam)==1){
               m_cb2.SetSelectedIndex((int)MathMax(0,(int)MathMin(StringToInteger(m_cb2.Value()),59)));
               m_NewTime=SolveTime(m_TimeStr.year,m_TimeStr.mon,m_TimeStr.day,m_TimeStr.hour,m_cb2.SelectedIndex(),m_TimeStr.sec);
               SetValueDateTime(m_NewTime);
               m_lineoff=true;
            }
            if(m_cb3.Event(id,lparam,dparam,sparam)==1){
               m_cb3.SetSelectedIndex((int)MathMax(0,(int)MathMin(StringToInteger(m_cb3.Value()),59)));
               m_NewTime=SolveTime(m_TimeStr.year,m_TimeStr.mon,m_TimeStr.day,m_TimeStr.hour,m_TimeStr.min,m_cb3.SelectedIndex());
               SetValueDateTime(m_NewTime);
               m_lineoff=true;
            }            
            if(m_cb.Event(id,lparam,dparam,sparam)==1){
               m_NewTime=SolveTime(m_TimeStr.year,m_cb.SelectedIndex()+1,m_TimeStr.day,m_TimeStr.hour,m_TimeStr.min,m_TimeStr.sec);
               SetValueDateTime(m_NewTime);
               m_lineoff=true;
            }
            if(m_sb.Event(id,lparam,dparam,sparam)){
               m_NewTime=SolveTime((int)m_sb.Value(),m_TimeStr.mon,m_TimeStr.day,m_TimeStr.hour,m_TimeStr.min,m_TimeStr.sec);
               SetValueDateTime(m_NewTime);
               m_lineoff=true;
            }
            if(id==CHARTEVENT_OBJECT_CLICK){
               if(sparam==m_Name+"_Ok"){
                  Sleep(100);
                  g.SetState(sparam,false);
                  g.Redraw();
                  Sleep(100);
                  Hide();
                  return(1);
               }
               if(sparam==m_Name+"_Cancel"){
                  Sleep(100);
                  g.SetState(sparam,false);
                  g.Redraw();
                  Sleep(100);
                  Hide();
               }               
               if(sparam==m_Name+"_Left"){
                  if(g.State(sparam)){
                     Sleep(50);
                     g.SetState(sparam,false);
                        if(m_cb.SelectedIndex()>0){
                           m_cb.SetSelectedIndex(m_cb.SelectedIndex()-1);
                           m_NewTime=SolveTime((int)m_sb.Value(),m_cb.SelectedIndex()+1,m_TimeStr.day,m_TimeStr.hour,m_TimeStr.min,m_TimeStr.sec);
                           SetValueDateTime(m_NewTime);
                           m_lineoff=true;
                        }
                        else{
                           if(m_sb.Value()>1970){
                              m_cb.SetSelectedIndex(11);
                              m_sb.SetValue(m_sb.Value()-1);
                              m_NewTime=SolveTime((int)m_sb.Value(),m_cb.SelectedIndex()+1,m_TimeStr.day,m_TimeStr.hour,m_TimeStr.min,m_TimeStr.sec);
                              SetValueDateTime(m_NewTime);
                              m_lineoff=true;
                           }
                        }   
                     g.Redraw();
                  }                     
               }            
               if(sparam==m_Name+"_Right"){
                  if(g.State(sparam)){
                     Sleep(50);
                     g.SetState(sparam,false);
                        if(m_cb.SelectedIndex()<11){
                           m_cb.SetSelectedIndex(m_cb.SelectedIndex()+1);
                           m_NewTime=SolveTime((int)m_sb.Value(),m_cb.SelectedIndex()+1,m_TimeStr.day,m_TimeStr.hour,m_TimeStr.min,m_TimeStr.sec);
                           SetValueDateTime(m_NewTime);
                           m_lineoff=true;
                        }
                        else{
                           m_cb.SetSelectedIndex(0);
                           m_sb.SetValue(m_sb.Value()+1);
                           m_NewTime=SolveTime((int)m_sb.Value(),m_cb.SelectedIndex()+1,m_TimeStr.day,m_TimeStr.hour,m_TimeStr.min,m_TimeStr.sec);
                           SetValueDateTime(m_NewTime);
                           m_lineoff=true;
                        }
                     g.Redraw();
                  }  
               }
               if(StringFind(sparam,m_Name+"_D_",0)==0){
                  int m_prelen=StringLen(m_Name+"_D_");
                  int m_p1=StringFind(sparam,"_",m_prelen);
                  int m_i=(int)StringToInteger(StringSubstr(sparam,m_prelen,m_p1-m_prelen));
                  int m_j=(int)StringToInteger(StringSubstr(sparam,m_p1+1,StringLen(sparam)-m_p1-1));
                     if(m_Cell[m_i][m_j].Year>=1970){
                        m_NewTime=SolveTime(m_Cell[m_i][m_j].Year,m_Cell[m_i][m_j].Month,m_Cell[m_i][m_j].Day,m_TimeStr.hour,m_TimeStr.min,m_TimeStr.sec);
                           if(m_NewTime!=m_TimeValue){
                              SetValueDateTime(m_NewTime);
                              m_lineoff=true;
                           }
                     }
                  
               }
               if(sparam==m_Name+"_CDMB"){
                  g.Attach(sparam);
                     if(g.State()){
                        Sleep(50);
                        g.SetState(false);                           
                        m_NewTime=SolveTime(m_ToDayStr.year,m_ToDayStr.mon,m_ToDayStr.day,m_TimeStr.hour,m_TimeStr.min,m_TimeStr.sec);
                           if(m_NewTime!=m_TimeValue){
                              SetValueDateTime(m_NewTime);
                              m_lineoff=true;
                           }
                           else{
                              ChartRedraw();
                           }
                                                   
                     }  
               }
               
               if(sparam==m_Name+"_CTMB"){
                  g.Attach(sparam);
                     if(g.State()){
                        Sleep(50);
                        g.SetState(false);                           
                        m_NewTime=SolveTime(m_TimeStr.year,m_TimeStr.mon,m_TimeStr.day,m_ToDayStr.hour,m_ToDayStr.min,m_ToDayStr.sec);
                           if(m_NewTime!=m_TimeValue){
                              SetValueDateTime(m_NewTime);
                              m_lineoff=true;
                           }
                           else{
                              ChartRedraw();
                           }                           
                                                   
                     }  
               }   
               if(sparam==m_Name+"_Line"){
                  if(g.State(sparam)){
                     datetime m_dta[1];                
                     int m_bn=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR)-(int)ChartGetInteger(0,CHART_WIDTH_IN_BARS)/2;
                     m_bn=(int)MathMax(m_bn,0);
                        if(CopyTime(Symbol(),Period(),m_bn,1,m_dta)==-1){
                           g.SetState(sparam,false);                           
                        }
                        else{
                           g.CreateVLine(m_Name+"_VLine");
                           g.SetColor(Red);
                           g.SetWidth(1);
                           g.SetStyle(STYLE_SOLID);
                           g.SetSelectable(true);
                           g.SetSelected(true);    
                           g.SetRay(true);
                           g.SetBack(true);
                           g.SetTime(0,m_dta[0]);
                           ChartRedraw();
                           SetValueDateTime(g.Time(0));
                        }
                     
                  }
                  else{
                     m_lineoff=true;
                  }
               }            
               if(m_lineoff){
                  if(g.State(m_Name+"_Line") || g.Find(m_Name+"_VLine")>=0){
                     g.SetState(m_Name+"_Line",false);
                     g.Delete(m_Name+"_VLine");
                     g.Redraw();
                  }
               }
            }
            if(id==CHARTEVENT_OBJECT_DRAG){
               if(sparam==m_Name+"_VLine"){
                  SetValueDateTime(g.Time(sparam,0));
                  ChartRedraw();
               }
            }
         return(0);
      }
		/*!	
			Setting subwindow by index.
			\param int aNumber - subwindow index.
 		*/       
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
                  m_cb.SetSubWindow(m_SubWindow);
                  m_sb.SetSubWindow(m_SubWindow);
                  m_cb1.SetSubWindow(m_SubWindow);
                  m_cb2.SetSubWindow(m_SubWindow);
                  m_cb3.SetSubWindow(m_SubWindow);    
                  Refresh();
            }
      }  
		/*!	
			Setting subwindow by subwindow name.
			\param string aName - subwindow name.
 		*/              
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }
		/*!	
			Setting the tag.
			\param string aValue - text.
 		*/  
      void SetTag(string aTag){
         m_Tag=aTag;
      }
		/*!	
			Getting the tag.
			\return Value (string type).
 		*/       
      string Tag(string aTag){
         return(m_Tag);
      }  
		/*!	
			Getting visibility.
			\return Value (bool type).
 		*/ 
      bool Visible(){
         return(m_Visible);
      }      
   
};

//+------------------------------------------------------------------+
//|         CCalendarInputBox class                                  |
//+------------------------------------------------------------------+

/*!
   \brief   "Date-time entering" graphical element.
   \details Several operation modes: entering date, entering time, entering date and time, 
            additional mode with the vertical line.
*/

class CCalendarInputBox{
   private:
      int m_SubWindow;
      int m_Left;
      int m_Top;
      int m_Width;
      int m_Height;
      string m_Name;
      string m_DName;
      string m_IName;
      string m_BName;
      string m_LName;
      string m_Caption;
      CCalendar m_d;
      CInputBox m_ib;
      color m_ColDBg;
      color m_ColDTx;
      color m_ColL;
      int m_cc;
      bool m_Visible;
      string m_Tag;
         void Create(){
            w.Edit(m_BName,m_SubWindow,m_Left+m_Width-13,m_Top,13,m_Height,"d",m_ColDBg,m_ColDTx,7,"Arial");
            g.SetReadOnly(m_BName,true);               
               if(m_Caption!=""){ // There is a label
                  w.Label(m_LName,m_SubWindow,m_Left+m_Width+1,m_Top+2,m_Caption,m_ColL,7,"Arial"); // Label creation
               } 
         }      
         void Delete(){
            ObjectDelete(0,m_BName);
            ObjectDelete(0,m_LName);            
         }
   public:
      /*!
         Initialization.
            string aName="CCalendar" - control element name,
            bool aDate=true - date entering is used,
            bool aTime=true - time entering is used,
            bool aSeconds=true - time within the accuracy of seconds,
            bool aLine=true - the vertical line entering is used (additionally to date and/or time entering),
            int aTimeMode=0 - current time type (0 - terminal time, 2 - local time),
            string aCaption - label text.
      */    
      void Init(string aName="CCalendarInput",bool aDate=true,bool aTime=true,bool aSeconds=true,bool aLine=true,int aTimeMode=0,string aCaption="CCalendarInput"){
         m_Name=aName;
         // Colors
         m_ColDBg=ClrScheme.Color(4);  // Button color
         m_ColDTx=ClrScheme.Color(1);  // Button label (sign) color
         m_ColL=ClrScheme.Color(2);    // Label color
         // Width
            if(aDate){
               if(aTime){
                  if(aSeconds){
                     m_Width=105; 
                  }
                  else{
                     m_Width=90; 
                  }
               }
               else{
                  m_Width=65; 
               }
            }
            else{
               if(aTime){
                  if(aSeconds){
                     m_Width=55; 
                  }
                  else{
                     m_Width=45; 
                  }
               }
               else{
                  m_Width=105; 
               }
            }
         m_Visible=false;
         m_Left=0;
         m_Top=0;
         m_Height=15;
         m_Caption=aCaption;
         m_DName=aName+"_D";
         m_IName=aName+"_I";
         m_BName=aName+"_B";
         m_LName=aName+"_L";
         m_cc=0;
         m_Tag="";  
         m_ib.Init(m_IName,m_Width-12,-1,""); // Input field initialization
         m_ib.SetReadOnly(true);
         m_d.Init(m_DName,aDate,aTime,aSeconds,aLine,aTimeMode);
         m_ib.SetValue(m_d.DateTimeString());
      }
		/*!	
			Setting "read only" parameter.
			\param int aValue - true/false - read only/editing is allowed.
 		*/         
      void SetReadOnly(bool aValue){
         m_ib.SetReadOnly(aValue);
      }
		/*!	
			Getting "read only" parameter.
			\return Тип bool. True/false - read only/editing is allowed.
 		*/       
      bool ReadOnly(){
         return(m_ib.ReadOnly());
      }      
		/*!	
			Setting width.
            \param		int aWidth - width.
            \remark	   If the control element is displayed, update using Refresh() method is required.
 		*/ 
      void SetWidth(int aValue){
         m_Width=aValue;
         m_ib.SetWidth(m_Width-12);
      }  
		/*!	
			Getting width.
			\return  Value (int type).
			\remark  Only the value of the text field without considering the label width.
 		*/        
      int Width(){
         return(m_Width);
      }
		/*!	
			Getting height.
			\return  Value (int type).
 		*/       
      int Height(){
         return(m_Height);
      }   
		/*!	
			Getting X coordinate.
			\return  Value (int type).
 		*/       
      int Left(){
         return(m_Left);
      }
		/*!	
			Getting Y coordinate.
			\return  Value (int type).
 		*/       
      int Top(){
         return(m_Top);
      }
		/*!	
			Updating (hiding and displaying with new parameters).
 		*/         
      void Refresh(){
         if(m_Visible){
            Delete();
            m_d.Hide();            
            m_ib.Hide();
            Show();
         }
      }
		/*!	
			Setting X and Y coordinates.
            \param		int aLeft - X coordinate (the distance from the chart's left margin),
            \param		int aTop - Y coordinate (the distance from the chart's upper margin).
            \remark	   If the control element is displayed, update using Refresh() method is required.
 		*/       
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;
         m_ib.SetPos(m_Left,m_Top);
      }
		/*!	
			Setting X coordinate.
            \param		int aLeft - X coordinate (the distance from the chart's left margin).
            \remark	   If the control element is displayed, update using Refresh() method is required.
 		*/  
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
         m_ib.SetPosLeft(m_Left);
      }  
		/*!	
			Setting Y coordinate.
            \param		int aTop - Y coordinate (the distance from the chart's upper margin).
            \remark	   If the control element is displayed, update using Refresh() method is required.
 		*/   
      void SetPosTop(int aTop){
         m_Top=aTop;
         m_ib.SetPosTop(m_Top);
      }
		/*!	
			Enabling visibility.
 		*/         
      void Show(){
         m_Visible=true;
         Create();
         m_ib.Show();
      }
		/*!	
			Enabling visibility on a specified position.
         \param		int aLeft - X coordinate (the distance from the chart's left margin),
         \param		int aTop - Y coordinate (the distance from the chart's upper margin).			
 		*/       
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      }
		/*!	
			Hiding control element (graphical objects removal).
 		*/        
      void Hide(){
         m_Visible=false;
         Delete();
         m_d.Hide();            
         m_ib.Hide();
      }
		/*!	
			Getting numerical value.
			\return Value (datetime type).
 		*/ 
      datetime ValueDateTime(){
         return(m_d.DateTimeValue());
      }
		/*!	
			Getting a string value.
			\return Value (string type).
 		*/ 
      string ValueString(){
         return(m_d.DateTimeString());
      }      
		/*!	
			Setting the value. 
         \param		datetime aValue - value.
 		*/        
      void SetValueDateTime(datetime aDateTime){
         m_d.SetValueDateTime(aDateTime);
         m_ib.SetValue(m_d.DateTimeString());
      }
		/*!	
			Events processing method.
			\remark  The method is called from the OnChartEvent() function, all parameters correspond to the OnChartEvent() function parameters.
			\return  0 or 1. 0 - no event. 1 – new value is entered.
 		*/        
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_event=0;
            if(sparam==""){
               if(id==CHARTEVENT_CLICK){
                  m_cc++;
                     if(m_cc>=2){
                        if(m_d.Visible()){
                           m_d.Hide();
                        }
                     }
               }                  
            }
            else{
               m_cc=0;
                  if(m_ib.Event(id,lparam,dparam,sparam)==1){
                     m_event=1;
                  }
               int m_dev=m_d.Event(id,lparam,dparam,sparam);
                  if(m_dev==1){
                     string m_oldvalue=m_ib.ValueString();
                        m_ib.SetValue(m_d.DateTimeString());
                        if(m_oldvalue!=m_d.DateTimeString()){
                           m_event=1;
                        }
                     ChartRedraw();
                  }
                  if(id==CHARTEVENT_OBJECT_CLICK){
                     if(sparam==m_BName){
                        if(m_d.Visible()){
                           m_d.Hide();
                        }  
                        else{
                           int m_w=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,m_SubWindow)/2;
                           int m_h=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,m_SubWindow)/2;
                           int m_x=m_Left+m_Width/2;
                           int m_y=m_Top+m_Height/2;
                           int m_cx;
                           int m_cy;
                              if(m_x<m_w){
                                 m_cx=m_Left;
                              }
                              else{
                                 m_cx=m_Left-m_d.Width()+m_Width;
                              }
                              if(m_y<m_h){
                                 m_cy=m_Top+m_ib.Height()-1;
                              }
                              else{
                                 m_cy=m_Top-m_d.Height()+1;
                              }                           
                           m_d.Show(m_cx,m_cy);
                        }                      
                     }
                     else{
                        if(m_dev!=2){
                           if(m_d.Visible()){
                              if(StringFind(sparam,m_Name,0)!=0){
                                 m_d.Hide();
                              }
                           } 
                        }
                     }
                  }
            }
            
         return(m_event);
      }
		/*!	
			Setting the tag.
			\param string aValue - text.
 		*/        
      void SetTag(string aTag){
         m_Tag=aTag;
      }
		/*!	
			Getting the tag.
			\return Value (string type).
 		*/       
      string Tag(){
         return(m_Tag);
      } 
		/*!	
			Setting subwindow by index.
			\param int aNumber - subwindow index.
 		*/          
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               m_ib.SetSubWindow(m_SubWindow);
               m_d.SetSubWindow(m_SubWindow);               
               Refresh();
            }
      }  
		/*!	
			Setting subwindow by subwindow name.
			\param string aName - subwindow name.
 		*/               
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }  
		/*!	
			Getting the warning mode.
			\return bool type. True/false - warning/normal.
 		*/          
      bool Warning(){
         return(m_ib.Warning());
      }     
		/*!	
			Enabling/disabling the warning color.
			\param bool aValue - true/false (warning/normal). 
 		*/                    
      void SetWarning(bool aValue){
         m_ib.SetWarning(aValue);
      }
		/*!	
			Updating current time.
 		*/    
      void TimeNowRefresh(){
         m_d.TimeNowRefresh();
      }
};

//+------------------------------------------------------------------+
//|         CFormBase Class                                          |
//+------------------------------------------------------------------+

/*!
   \brief   Base class of the form. It is used to create forms with controls.
   \details You do not have to change anything in this class in order to use it 
            in your work. For a more detailed information regarding the creation of forms 
            please see the description of CFormTemplate class.
   \remark	This control consists of several graphical objects 
            "Rectangle Label" (OBJ_RECTANGLE_LABEL) and a few 
            buttons (OBJ_BUTTON). The exact set of graphical objects
            depends on the type of the form and its operating mode. Names of all graphical
            objects start with the form name; in order to get the name of an object
            forming the workspace if the form, "_Form" is added to the form name,
            "_Upper" is added for the top bar with a caption, "_Caption" is added for a caption 
            with the heading, "_Lower" is added for the bottom bar with buttons, "_Cancel" is added
            for "Close" or "Cancel" buttons, "_Apply" is added for the "Apply" button, "_Move"
            is added for the move button, "_Min" is added for minimizing/maximizing
            button, "_Close" is added for the close button (with a cross image)
            situated in the top right corner.
*/

class CFormBase{
   protected:
      color m_MainColor; 
      color m_BorderColor;
      color m_TxtColor;
      color m_UpperColor;
      color m_LowerColor;
      color m_UpperTxtColor;
      color m_ButColor;
      int m_Type;   
      int m_SubWindow;
      string m_Name;
      int m_Width;
      int m_Height;
      int m_Left;
      int m_Top;      
      string m_Caption;
      bool m_MoveMode;
      long m_Tc;
      int m_State;
      string m_Tag;
      bool m_Movable;
      bool m_Resizable;
      bool m_CloseButton;
      int m_SpaceLeft;
      int m_SpaceTop;
      bool m_Visible;
         virtual void OnShowEvent(int aLeft,int aTop){
         }
         virtual void OnHideEvent(){
         }
         virtual void EventsHandler(const int id,const long& lparam,const double& dparam,const string& sparam){
         }
         virtual bool OnCancelEvent(){
            return(true);
         }
         virtual bool OnApplyEvent(){
            return(true);
         } 
         virtual void MainProperties(){
         }
         virtual void OnInitEvent(){
         }
         virtual void OnWindowChangeEvent(int aSubWindow){
         }
         bool PosCorrection(){
            int m_chw=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,m_SubWindow);
            int m_chh=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,m_SubWindow);
               if(m_chw<=0 || m_chh<=0){
                  return(false);
               }
            int m_mxleft=m_chw-Width();
            int m_mxtop=m_chh-Height();
            int m_oldleft=m_Left;
            int m_oldtop=m_Top;
            m_Left=(int)MathMin(m_Left,m_mxleft);
            m_Left=(int)MathMax(m_Left,0);
            m_Top=(int)MathMin(m_Top,m_mxtop);
            m_Top=(int)MathMax(m_Top,0);
            m_SpaceLeft=m_Left;
            m_SpaceTop=m_Top+16;
            return(m_oldleft!=m_Left || m_oldtop!=m_Top);
         }
         void CreateForm(){
            if(m_State==0)return;
            PosCorrection();          
            if(m_State!=2)w.Canvas(m_Name+"_Form",m_SubWindow,m_Left,m_Top,m_Width,m_Height,m_MainColor,m_BorderColor);
            w.Canvas(m_Name+"_Upper",m_SubWindow,m_Left,m_Top,m_Width,17,m_UpperColor,m_BorderColor);
            int m_xshift=15;
               if(m_CloseButton){
                  w.Button(m_Name+"_Close",m_SubWindow,m_Left+m_Width-15,m_Top+2,13,13,CharToString(251),m_ButColor,m_TxtColor,10,"Wingdings");
                  m_xshift=29;
               }                  
               if(m_Resizable){
                  w.Button(m_Name+"_Min",m_SubWindow,m_Left+m_Width-m_xshift,m_Top+2,13,13,CharToString(168),m_ButColor,m_TxtColor,7,"Wingdings");
               }                  
            m_xshift=4;
               if(m_Movable){
                  w.Button(m_Name+"_Move",m_SubWindow,m_Left+2,m_Top+2,13,13,CharToString(73),m_ButColor,m_TxtColor,8,"Wingdings");
                  m_xshift=16;
               }                  
            w.Label(m_Name+"_Caption",m_SubWindow,m_Left+m_xshift,m_Top+2,m_Caption,m_UpperTxtColor);
               if(m_State!=2){
                     switch(m_Type){
                        case 1:
                           w.Canvas(m_Name+"_Lower",m_SubWindow,m_Left,m_Top+m_Height-18,m_Width,18,m_LowerColor,m_BorderColor);
                           w.Button(m_Name+"_Apply",m_SubWindow,m_Left+m_Width-42,m_Top+m_Height-16,40,14,"Apply",m_ButColor,m_TxtColor);
                           w.Button(m_Name+"_Cancel",m_SubWindow,m_Left+2,m_Top+m_Height-16,40,14,"Cancel",m_ButColor,m_TxtColor);
                        break;
                        case 2:
                           w.Canvas(m_Name+"_Lower",m_SubWindow,m_Left,m_Top+m_Height-18,m_Width,18,m_LowerColor,m_BorderColor);
                           w.Button(m_Name+"_Cancel",m_SubWindow,m_Left+m_Width/2-20,m_Top+m_Height-16,40,14,"Close",m_ButColor,m_TxtColor);
                        break;
                     }
                  OnShowEvent(m_SpaceLeft,m_SpaceTop);
               }      
            
         }
         void DeleteForm(){
            OnHideEvent();
            ObjectDelete(0,m_Name+"_Form");
            ObjectDelete(0,m_Name+"_Upper");
            ObjectDelete(0,m_Name+"_Close");
            ObjectDelete(0,m_Name+"_Min");
            ObjectDelete(0,m_Name+"_Move");
            ObjectDelete(0,m_Name+"_Caption");
            ObjectDelete(0,m_Name+"_Lower");
            ObjectDelete(0,m_Name+"_Apply");
            ObjectDelete(0,m_Name+"_Cancel");      
         } 
         void ChartClickY(double aDparam,int & aY){
            long hs=0;
            long ps=0;
               for(int i=0;i<ChartGetInteger(0,CHART_WINDOWS_TOTAL);i++){
                  hs+=3+ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,i);
                     if(hs>=aDparam){
                        aY=(int)(aDparam-ps-3); 
                        break;
                     }
                  ps=hs;
               } 
         }  
         void WhenChartResize(){
            if(m_State!=0){
               if(PosCorrection()){
                  Refresh();
               }
            }
         }
   public:
		/*!	
			Form initialization.
			\param		int aState=1 - state of the form upon enabling its visibility: 1 - maximized, 2 - minimized
 		*/      
      void Init(int aState=1){
         m_Visible=false;
         m_SubWindow=0;
         m_MainColor=ClrScheme.Color(32);      // Main color of the field for controls
         m_BorderColor=ClrScheme.Color(33);    // Border color
         m_ButColor=ClrScheme.Color(34);       // Button color
         m_TxtColor=ClrScheme.Color(35);       // Button caption color
         m_UpperColor=ClrScheme.Color(36);     // Top bar color
         m_LowerColor=ClrScheme.Color(37);     // Bottom bar color
         m_UpperTxtColor=ClrScheme.Color(38);  // Top bar caption color
         m_Tag="";
         m_MoveMode=false;
         m_State=aState;
         m_SpaceLeft=0;
         m_SpaceTop=16;         
         MainProperties();
         OnInitEvent();
      }
		/*!	
			Setting the X- and Y-coordinates of the form.
            \param		int aLeft - X-coordinate (distance from the left side of the chart),
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/  
      void SetPos(int aLeft,int aTop){
         m_Left=aLeft;
         m_Top=aTop;  
         m_SpaceLeft=m_Left;
         m_SpaceTop=m_Top+16;               
      }
		/*!	
			Setting the X-coordinate of the form.
            \param		int aLeft - X-coordinate (distance from the left side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/           
      void SetPosLeft(int aLeft){
         m_Left=aLeft;
         m_SpaceLeft=m_Left;         
      }
		/*!	
			Setting the Y-coordinate of the form.
            \param		int aTop - Y-coordinate (distance from the top side of the chart).
            \remark	   If the control is displayed, a refresh by the Refresh() method is required.
 		*/        
      void SetPosTop(int aTop){
         m_Top=aTop;   
         m_SpaceTop=m_Top+16;       
      }  
		/*!	
			Enabling the form visibility.
 		*/  
      void Show(){
         m_Visible=true;
         CreateForm();  
         ChartRedraw();            
      } 
		/*!	
			Enabling the form visibility at a set position.
         \param		int aLeft - X-coordinate (distance from the left side of the chart),
         \param		int aTop - Y-coordinate (distance from the top side of the chart).
 		*/       
      void Show(int aLeft,int aTop){
         SetPos(aLeft,aTop);
         Show();
      } 
		/*!	
			Hiding the form (deletion of all graphical objects of the form).
 		*/        
      void Hide(){
         m_Visible=false;
         DeleteForm();
         ChartRedraw(0);
      }
		/*!	
			Refresh (hiding and displaying with new parameters).
 		*/         
      void Refresh(){
         if(m_State!=0){
            DeleteForm();
            CreateForm();
            ChartRedraw();
         }            
      }
		/*!	
			Getting the form width.
			\return  Value (int type).
 		*/        
      int Width(){
         return(m_Width);
      }     
		/*!	
			Getting the current height of the form.
			\return  Value (int type).
 		*/        
      int Height(){
            switch(m_State){
               case 1:
                  return(HeightMax());
               break;
               case 2:
                  return(HeightMin());
               break;
            }
         return(0);
      }   
		/*!	
			Getting the height of the form in the maximized state.
			\return  Value (int type).
 		*/          
      int HeightMax(){
         return(m_Height);
      }    
		/*!	
			Getting the height of the form in the minimized state.
			\return  Value (int type).
 		*/         
      int HeightMin(){
         return(17);
      }
		/*!	
			Getting the X-coordinate.
			\return  Value (int type).
 		*/       
      int Left(){ // Getting the X-coordinate
         return(m_Left);
      }
		/*!	
			Getting the Y-coordinate.
			\return  Value (int type).
 		*/        
      int Top(){ // Getting the Y-coordinate
         return(m_Top);
      }      
		/*!	
			Setting the form state.
            \param		int aState - 1 - maximized, 2 - minimized.
 		*/         
      void SetState(int aState=1){
         if(aState>=1 && aState<=2){
            m_State=aState;
               if(m_Visible){
                  Refresh();
               }   
         }             
      } 
		/*!	
			Getting the form state.
			\return  Value (int type). 0 - hidden, 1 - maximized, 2 - minimized.
 		*/               
      int State(){
         return(m_State);
      } 
		/*!	
			Getting the form name.
			\return  Text (string type).
 		*/                        
      string Name(){
         return(m_Name);
      }
		/*!	
			Getting the form heading.
			\return  Text (string type).
 		*/        
      string Caption(){
         return(m_Caption);
      }  
		/*!	
			Setting a tag.
			\param string aValue - text.
 		*/  
      void SetTag(string aTag){
         m_Tag=aTag;
      }
		/*!	
			Getting a tag.
			\return Value (string type).
 		*/       
      string Tag(string aTag){
         return(m_Tag);
      }      
		/*!	
			Defining the subwindow by the number.
			\param int aNumber - subwindow number.
 		*/         
      void SetSubWindow(int aNumber){
         int m_itmp=(int)MathMax(aNumber,0);
            if(m_itmp!=m_SubWindow){
               m_SubWindow=m_itmp;
               m_MoveMode=false;
                  if(m_Visible){
                     Hide();
                     OnWindowChangeEvent(m_itmp);
                     Show();                  
                      
                  }
                  else{
                     OnWindowChangeEvent(m_itmp);  
                  }                     
            }
      } 
		/*!	
			Defining the subwindow by the subwindow name.
			\param string aName - subwindow name.
 		*/                
      void SetSubWindow(string aName){
         SetSubWindow(ChartWindowFind(0,aName));
      }  
		/*!	
			Event handling method.
			\remark  The method is called from the OnChartEvent() function; all parameters correspond to the OnChartEvent() function parameters.
			\return  0, 1, 2 or 3. 0 - no event. 1 – "Cancel" event occurs when clicking the "Cancel", "Close" buttons or button with a cross image, 2 - "Apply" event occurs when clicking the "Apply" button, 3 - "Resize" event occurs when minimizing and maximizing the form, 4  is the event of clicking on the main space of the form.
 		*/       
      int Event(const int id,const long& lparam,const double& dparam,const string& sparam){
         int m_rv=0;   
            if(!m_MoveMode){
               EventsHandler(id,lparam,dparam,sparam);
                  if(id==CHARTEVENT_OBJECT_CLICK){
                     if(sparam==m_Name+"_Form"){
                        m_rv=4;   
                     }
                     if(sparam==m_Name+"_Close"){
                        Sleep(150);
                        g.Attach(m_Name+"_Close");
                        g.SetState(false);
                        g.Redraw();
                        Sleep(150);
                           if(OnCancelEvent()){
                              Hide();
                              m_rv=1;
                           }
                     }
                     if(sparam==m_Name+"_Cancel"){
                        Sleep(150);
                        g.Attach(m_Name+"_Cancel");
                        g.SetState(false);
                        g.Redraw();
                        Sleep(150);               
                           if(OnCancelEvent()){
                              Hide();
                              m_rv=1;
                           }
                     }
                     if(sparam==m_Name+"_Apply"){
                        Sleep(150);
                        g.Attach(m_Name+"_Apply");
                        g.SetState(false);
                        g.Redraw();
                        Sleep(150);               
                           if(OnApplyEvent()){
                              Hide();
                              m_rv=2;
                           }
                     }   
                     if(sparam==m_Name+"_Min"){
                        Sleep(150);
                        g.Attach(m_Name+"_Min");
                        g.SetState(false);
                        g.Redraw();
                        Sleep(150);
                           if(m_State==1){
                              SetState(2);
                           }
                           else if(m_State==2){
                              SetState(1);
                           }
                        m_rv=3;                   
                     }
                  }
            }
            if(sparam==m_Name+"_Move"){
               g.Attach(m_Name+"_Move");
               m_MoveMode=g.State();
               m_Tc=GetTickCount();
            }            
            if(id==CHARTEVENT_CLICK){
               if(m_MoveMode){
                  if(GetTickCount()>m_Tc+300){
                     m_MoveMode=false;
                     int m_Y;
                     ChartClickY(dparam,m_Y);
                     SetPos((int)lparam-3,m_Y);
                     Refresh();
                  }                  
               }
            }
            if(CHARTEVENT_CHART_CHANGE){
               WhenChartResize();
            }
         return(m_rv);            
      }
};

//+------------------------------------------------------------------+
//|         CFormTemplate Subclass: public CFormBase                 |
//+------------------------------------------------------------------+

/*!
   \brief   A subclass of CFormBase class for creation of forms with 
            controls.
   \details In order to create a form, you should make a copy 
            of the code of CFormTemplate class: public CFormBase with a unique name, i.e.
            simply copy the class code and rename it, e.g.
  
               CForm1: public CFormBase;
               
            Set the main properties of the form by setting values to the variables in the MainProperties() method.
            
            Declare the class, e.g.
            
               CForm1 frm;
         
            Then do the following steps:      
            
               01.   Declare the controls. It is executed in the public section of the form class.
         
               02.   Declare the variables for restoring the values.
         
               03.   Call the Init() methods of all the controls. It is executed in the OnInitEvent() method. 
                     Names of all the controls are advised to start with the form name m_Name. 
         
               04.   Load the previously saved data (e.g. from a file) in the OnInitEvent() method, where necessary.
         
               05.   Prepare the controls for utilization in the OnInitEvent() method, where necessary.
         
               06.   Call the Show(x,y) methods of all the controls. It is executed in the OnShowEvent() method. 
                     Values of m_SpaceLeft and m_SpaceTop variables are added to X- and Y-coordinates of all the controls .
         
               07.   Call the Hide() methods of all the controls. It is executed in the OnHideEvent() method.
         
               08.   Call the SetSubWindow() methods of all the controls. It is executed in the OnWindowChangeEvent() method.
         
               09.   Call the Event() methods of all the controls. This is executed in the EventsHandler() method. 
         
               10.   Handle the control events according to the objectives and purposes of their utilization in the EventsHandler() method.
         
               11.   Check the control values, where necessary, in the OnApplyEvent() method.
         
               12.   Save the control values (e.g. in a file), where necessary, in the OnApplyEvent() method.
         
               13.   Run the checks in the OnCancelEvent() method, where necessary.
   
   \remark  This subclass does not have any public methods.
*/

class CFormTemplate: public CFormBase{
   public:
      // 1. Declaring the controls  
      
   protected: 
      // 2. Declaring the variables to restore the control values
         void MainProperties(){
            // Setting the form parameters
            m_Name         =  "Form";        // Form name. The names of all the controls should start with it.
            m_Width        =  200;           // Form width
            m_Height       =  150;           // Form height
            m_Type         =  1;             // Form type: 0 - without buttons, 1 - with "Apply" and "Cancel" buttons, 2 - with the "Close" button
            m_Caption      =  "FormCaption"; // Form caption
            m_Movable      =  true;          // Movable form (the button with a hand image is displayed in the top left corner)
            m_Resizable    =  true;          // Form minimizing/maximizing allowed (the button with a rectangle image is displayed in the top right corner)
            m_CloseButton  =  true;          // Form closing allowed (the button with a cross image is displayed in the top right corner)
         }
         void OnInitEvent(){
            // 3. Calling the Init() methods of all the controls
            // 4. Loading the parameters from the data storage, where necessary
            // 5. Preparation of the controls, for example adding the list items.

         }   
         void OnShowEvent(int aLeft, int aTop){
            // 6. Calling the Show(x,y) method for all the controls of the form
      
         }
         void OnHideEvent(){
            // 7. Calling the Hide() method for all the controls of the form

         }
         void OnWindowChangeEvent(int aSubWindow){
            // 8. Calling the SetSubWindow() method for all the controls of the form. The subwindow number is conveyed by the aSubWindow parameter.

         }
         void EventsHandler(const int id,const long& lparam,const double& dparam,const string& sparam){
            // 9. Calling the Event() method of all the controls. 
            // 10. Handling the control events, where necessary

         }
         bool OnApplyEvent(){
            // 11. Checking the control values upon closing by the "Apply" button. In order to reject the closing of the form, false should be returned from this method.
            // 12. Saving the parameters.
            
            return(true);
         }
         bool OnCancelEvent(){
            // 13. Checks upon closing by the "Cancel" or "Close" buttons. In order to reject the closing of the form, false should be returned from this method.
            
            return(true);
         }
};