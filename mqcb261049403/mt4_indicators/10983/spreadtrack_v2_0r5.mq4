//+------------------------------------------------------------------------------------+
#define     _NAME_                  "SpreadTrack"
#define     _TITLE_                 "SpreadTrack (v2.0r5) - MetaTrader 4 Indicator"
#define     _ABSTRACT_              "OHLC History File Spread Tracker Indicator"
#property   copyright               "Copyright © 2013, Fernando M. I. Carreiro"
#property   link                    "mailto:fmi@carreiro.co.pt?subject=SpreadTrack.v2.0"
#property   indicator_chart_window
#property   indicator_buffers       0
//+------------------------------------------------------------------------------------+
//                                  Please note that the TAB Size is based on 4, not 3
//+------------------------------------------------------------------------------------+


//+------------------------------------------------------------------------------------+
//  Indicator Includes and Library References
//+------------------------------------------------------------------------------------+

#include <WinUser32.mqh>

//--- Declare Function somestimes not present in the "WinUser32.mqh" header file
    #import "user32.dll"
    int RegisterWindowMessageA(string lpstring);
    
    
//+------------------------------------------------------------------------------------+
//  Indicator Settings
//+------------------------------------------------------------------------------------+

    extern string
        strSymbolSuffix     = ".s"          // Suffix Text Applied to Symbol Name       
    ;


//+------------------------------------------------------------------------------------+
//  Declare Global/Overall Variables
//+------------------------------------------------------------------------------------+

    string
        strSymbol                           // Current Symbol used on Chart
    ,   strSymbolSpread                     // Label for current Symbol and suffix
    ;
    int
        intTimeFrame                        // Current TimeFrame/Period used on Chart
    ,   intHistoryFile                      // Handle to History File generated
    ,   intChartWindow                      // Handle to Chart Window
    ,   intMT4InternalMsg                   // Internal Message Handle
    ;


//---- Process Tick Spread Data
    datetime
        dtTimeSpread    = NULL
    ;
    double
        dblOpenSpread   = EMPTY
    ,   dblHighSpread   = EMPTY
    ,   dblLowSpread    = EMPTY
    ,   dblCloseSpread  = EMPTY
    ,   dblVolumeSpread = NULL
    ;
    void voidProcessTickSpread(
            double dblSpread, bool boolBarNew, datetime dtTimeStamp )
    {
        if ( boolBarNew )
        {
            if ( dblVolumeSpread > NULL )
                boolWriteFileHST( intHistoryFile,
                    dtTimeSpread,   dblOpenSpread,  dblHighSpread,
                    dblLowSpread,   dblCloseSpread, dblVolumeSpread );

            dtTimeSpread    = dtTimeStamp;
            dblOpenSpread   = dblSpread;
            dblHighSpread   = dblSpread;
            dblLowSpread    = dblSpread;
            dblCloseSpread  = dblSpread;
            dblVolumeSpread = 1;
        }
        else
        {
            dblCloseSpread  = dblSpread;

            if ( dblSpread > dblHighSpread )    dblHighSpread   = dblSpread;
            if ( dblSpread < dblLowSpread )     dblLowSpread    = dblSpread;

            dblVolumeSpread++;
        }
    }


//---- Initialise Indicator Data other Properties
    int init()
    {
        // Set Number of Digits (Precision)
        IndicatorDigits( Digits );

        // Set Indicator Name
        IndicatorShortName( _NAME_ );

        // Get Current Symbol Name and Current TimeFrame/Period
        intTimeFrame    = Period();
        strSymbol       = Symbol();
        strSymbolSpread = StringConcatenate( strSymbol, strSymbolSuffix );

        // Define Internal Message Handle
        intMT4InternalMsg = RegisterWindowMessageA( "MetaTrader4_Internal_Message" );
        
        // Initialise History File to be generated
        intHistoryFile = intInitFileHST( strSymbolSpread, intTimeFrame );

        // Verify that it is valid
        if ( intHistoryFile > NULL )
            Comment( StringConcatenate( _NAME_, ": Enabled" ) );
        else
            Comment( StringConcatenate( _NAME_, ": Disabled" ) );

        return( NULL );
    }


//---- Deinitialise Indicator Data other Properties
    int deinit()
    {
        if ( intHistoryFile > NULL )
        {
            FileFlush( intHistoryFile );
            FileClose( intHistoryFile );
        }

        intHistoryFile = EMPTY;

        Comment( "" );

        return( NULL );
    }


//---- Start Processing Data
    int start()
    {
        // Check if File Handle is Valid
        if ( intHistoryFile <= NULL ) return( NULL );

        // Check current Spread Value
        double dblSpread = Ask - Bid;
        if ( dblSpread < 0 ) dblSpread = -dblSpread;    // Just in Case, Ask < Bid

        // Check for a New Bar open
        static  datetime    dtTimeStamp;    // TimeStamp for New Bar detection
                bool        boolBarNew;     // Consider if a New Bar Opening

        if ( dtTimeStamp    != Time[ 0 ] )  // Check Bar Time if New Bar
        {
            dtTimeStamp     = Time[ 0 ];    // Time Stamp of Bar Opening
            boolBarNew      = true;         // Tick is first on New Bar
        }
        else
            boolBarNew      = false;        // New Tick but not New Bar

        // Process the Data
        voidProcessTickSpread( dblSpread, boolBarNew, dtTimeStamp );

        Comment(
            StringConcatenate(
                _NAME_, ": ", DoubleToStr( dblSpread, Digits ),
                " ", strSymbolSpread ) );

        if ( boolBarNew )
        {
            // Detect if Offline Chart is Open, Refresh in case chart is reopened
            intChartWindow = WindowHandle( strSymbolSpread, intHistoryFile );

            // Refresh Offline Chart Window
            if ( intChartWindow != NULL )
            {
                PostMessageA( intChartWindow, WM_COMMAND, 33324, 0 );

                // Incoming tick for EAs on Offline Chart
                if ( intMT4InternalMsg != NULL )
                    PostMessageA( intChartWindow, intMT4InternalMsg, 2, 1);
            }
        }

        return ( NULL );
    }

    
//---- Initialise OHLC History Chart File
    int intInitFileHST( string strSymbolHST, int intTimeFrameHST )
    {
        static string
            strCopyright    = "(C)opyright 2003, MetaQuotes Software Corp."
        ;
        static int intUnused[13]
        ;
        string
            strFileNameHST  = StringConcatenate( strSymbolHST, intTimeFrameHST, ".hst" )
        ;
        int
            intHandleHST    = FileOpenHistory( strFileNameHST, FILE_BIN | FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE)
        ;

        if ( intHandleHST <= NULL ) return( EMPTY );

        FileWriteInteger(   intHandleHST, 400,              LONG_VALUE  );
        FileWriteString(    intHandleHST, strCopyright,     64          );
        FileWriteString(    intHandleHST, strSymbolHST,     12          );
        FileWriteInteger(   intHandleHST, intTimeFrameHST,  LONG_VALUE  );
        FileWriteInteger(   intHandleHST, Digits,           LONG_VALUE  );
        FileWriteInteger(   intHandleHST, 0,                LONG_VALUE  );
        FileWriteInteger(   intHandleHST, 0,                LONG_VALUE  );
        FileWriteArray(     intHandleHST, intUnused,        0, 48       );
        FileFlush(          intHandleHST                                );

        return( intHandleHST );
    }


//---- Write/Save a OHLC Bar to History Chart File
    bool boolWriteFileHST(
            int         intHandleHST,
            datetime    dtTimeStamp,
            double      dblOpen, double dblHigh,
            double      dblLow,  double dblClose,
            double      dblVolume )
    {
        if ( intHandleHST <= NULL ) return( false );

        FileWriteInteger(   intHandleHST, dtTimeStamp,      LONG_VALUE      );
        FileWriteDouble(    intHandleHST, dblOpen,          DOUBLE_VALUE    );
        FileWriteDouble(    intHandleHST, dblLow,           DOUBLE_VALUE    );
        FileWriteDouble(    intHandleHST, dblHigh,          DOUBLE_VALUE    );
        FileWriteDouble(    intHandleHST, dblClose,         DOUBLE_VALUE    );
        FileWriteDouble(    intHandleHST, dblVolume,        DOUBLE_VALUE    );
        FileFlush(          intHandleHST                                    );

        return( true );
    }

