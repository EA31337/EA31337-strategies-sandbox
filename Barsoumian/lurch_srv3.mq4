//+------------------------------------------------------------------+
//|                                            MT4-LevelStop-Reverse |
//|                                                      Version 2.0 |
//|                Copyright © 2007-2008, Bruce Hellstrom (brucehvn) |
//|                                              bhweb@speakeasy.net |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

/////////////////////////////////////////////////////////////////////
// Version 2.0
//
// This is a port of the VTTrader VT-LevelStop-Reverse trading system.
// This is ported as an MT4 indicator only and perhaps can be evolved
// into an EA later.
//
/////////////////////////////////////////////////////////////////////

/*

This is a combination of two VT Trader trading systems.  The first is the default
VT-LevelStop-Reverse and the second is one that was modified to allow customizing
the ATR settings for calculating the stop line.  I've tried to combine these 2
versions into a single MT4 indicator.

The default VT version allows you to use two modes, optimized, and manual.
Optimized mode calculates the stop line by using a 14 period EMA smoothed
ATR(14) multiplied by a fixed multiplier of 2.824. In manual mode, you set a
fixed number of pips you want the stop line to be drawn. In my MT4 version,
there are two modes:

1. ATR mode (customizable ATR period, multiplier, and smoothing)
2. Fixed stop mode (customizable fixed stop)

The input parameters are as follows:

* UseATRMode -     This calculates the stop line based on ATR using customizable period, multiplier and smoothing.
* NonATRStopPips - If "UseATRMode" is false, then this value is the number of fixed pips to place the stop line.
* ATRPeriod -      If "UseATRMode" is true, then this sets the ATR period.
* ATRMultiplier -  If "UseATRMode" is true, then the ATR value will be multiplied by this value when calculating the stop line.
* ATRSmoothing -   If "UseATRMode" is true, then this will smooth the selected ATR with an EMA of this smoothing period.
* UpArrowColor -   The color the Up arrows will display in.
* DnArrowColor -   The color the Down arrows will display in.
* ArrowDistance -  This can adjust the distance away from the stop line that the arrows appear. By default, the arrows appear directly above or below the stop line. A positive number here will move the arrows further away from the price.  A negative number will move it closer to the price.
* AlertSound -     If true, this will sound an alert when the reverse condition has been triggered.
* AlertMail -      If true, will send email to the email address registered with MT4.
* ShowComment - This will turn on/off the comment on the chart.  Turn off if you have other indicators that put data there and you don't want it overwritten.

For the default VT-LevelStop-Reverse behavior, set the following:
UseATRMode = true
ATRPeriod = 14
ATRMultiplier = 2.824
ATRSmoothing = 14

To use this indicator, copy it to your <MetaTrader Folder>\experts\indicators folder. Then restart MT4. It will appear in the custom indicators list.

Revision History

Version Beta 0.2
* Minor bug fixes.
* Remove extra "UseVTDefault" option.
* Add smoothing option for compatibility with default VT version.

Version Beta 0.3
* Delete objects at startup.
* Use a more unique object name prefix.
* Change ATRBuffer and SmoothBuffer to be non-indicator buffers.
* No need for UpSignal and DnSignal to be buffers.
* Change arrows to display at the stop line.
* Fix bug on current bar drawing that would cause multiple arrows to appear.

Version Beta 0.4
* Fix bug in non-indicator buffers that was causing erroneous data in the ATR buffer and smoothing buffer.

Version 1.0
* Fix some problems with the original VT formula that caused arrows to be drawn incorrectly if the price closed at the exact same level as the stop line.Fix bug in non-indicator buffers that was causing erroneous data in the ATR buffer and smoothing buffer.
* Add some print statements for arrow tracking.
* Always smooth, just use 1 for a value if no smoothing is indicated.
* Add ShowComment option

Version 2.0
* Fix multiple arrows being drawn in the same place.
* Try to fix an issue where arrows sometimes disappear.
* Add alerts.
* Name arrow objects incrementally rather than via random number.
*/

#property copyright "Copyright © 2007-2008, Bruce Hellstrom (brucehvn)"
#property link      "http: //www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Magenta
#property indicator_style1 STYLE_DOT

#property indicator_color2 DodgerBlue
#property indicator_width2 1
#property indicator_color3 OrangeRed
#property indicator_width3 1

#define INDICATOR_VERSION "v2.0"
#define VTS_OBJECT_PREFIX "vtsbh2483-"


//---- input parameters

bool UseATRMode = true;
int NonATRStopPips = 40;
extern int ATRPeriod = 9;
extern double ATRMultiplier = 3.0;
int ATRSmoothing = 0;
int ArrowDistance = 0;
bool AlertSound = false;
bool AlertMail = false;
bool ShowComment = false;


//---- buffers
double TrStopLevel[];
double UpBuffer[];
double DownBuffer[];

//---- variables
double ATRBuffer[];
double SmoothBuffer[];
string ShortName;
datetime LastArrowTime = 0;
bool LastArrowSignal = 0;
datetime LastAlertBar = 0;
datetime CurrentBarTime = 0;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() 
{
    int DrawBegin = 0;
    if ( UseATRMode ) DrawBegin = ATRPeriod;
    
    // Set the smoothing to 1 if it is zero or less
    if ( ATRSmoothing <= 0 ) ATRSmoothing = 1;
    
    IndicatorBuffers( 3 );
    SetIndexStyle( 0, DRAW_LINE, STYLE_DOT, 1 );
    SetIndexBuffer( 0, TrStopLevel );
    SetIndexDrawBegin( 0, DrawBegin );
    
    SetIndexStyle(1,DRAW_ARROW);
    SetIndexArrow(1,233);
    SetIndexBuffer(1,UpBuffer);
    SetIndexEmptyValue(1,0.0);

    SetIndexStyle(2,DRAW_ARROW);
    SetIndexArrow(2,234);
    SetIndexBuffer(2,DownBuffer);
    SetIndexEmptyValue(2,0.0);

    ShortName = "MT4-LevelStop-Reverse-" + INDICATOR_VERSION + "(";
    
    if ( UseATRMode ) 
        ShortName = StringConcatenate( ShortName, "ATRMode ", ATRPeriod, ", ", ATRMultiplier, ", ", ATRSmoothing, " )" );
    else 
        ShortName = StringConcatenate( ShortName, "Manual Mode Stop = ", NonATRStopPips, " )" );
    
    IndicatorShortName( ShortName );
    SetIndexLabel( 0, ShortName );
    
    return( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
int deinit() 
{
    Comment("");
    return( 0 );
}

//+------------------------------------------------------------------+
//| Function run on every tick                                       |
//+------------------------------------------------------------------+
int start() 
{
    int ictr;
    int counted_bars = IndicatorCounted();
    
    // Check for errors
    if ( counted_bars < 0 ) return( -1 );

    // Last bar will be recounted
    if ( counted_bars > 0 ) counted_bars--;
    
    int limit = Bars - counted_bars;
    ictr = limit - 1;
    
    if ( UseATRMode && Bars < ATRPeriod ) return( 0 );
    
    // Make sure buffers are sized correctly
    int buff_size = ArraySize( TrStopLevel );
    if ( ArraySize( ATRBuffer ) != buff_size ) 
    {
        ArraySetAsSeries( ATRBuffer, false );
        ArrayResize( ATRBuffer, buff_size );
        ArraySetAsSeries( ATRBuffer, true );

        //ArraySetAsSeries( SmoothBuffer, false );
        //ArrayResize( SmoothBuffer, buff_size );
        //ArraySetAsSeries( SmoothBuffer, true );
    }
    
    int xctr;
    
    if ( UseATRMode ) 
    {
        // First calculate the ATR
        for ( xctr = 0; xctr < limit; xctr++ ) 
            ATRBuffer[xctr] = iATR( NULL, 0, ATRPeriod, xctr );
            
        // Smooth the ATR
        //for ( xctr = 0; xctr < limit; xctr++ )
        //    SmoothBuffer[xctr] = Wilders( ATRBuffer, ATRSmoothing, xctr );
    }
    
    
    for ( xctr = ictr; xctr >= 0; xctr-- ) {
         // Calculate the stop amount
        double DeltaStop = NonATRStopPips * Point;
        
        // Calculate our stop value based on ATR if required
        if ( UseATRMode ) DeltaStop = NormalizeDouble( iATR( NULL, 0, ATRPeriod, xctr ) * ATRMultiplier, Digits );
        
        // Figure out where the current bar's stop level should be
        double NewStopLevel;
        double PrevStop = TrStopLevel[xctr + 1];
        bool DrawUpArrow = false;
        bool DrawDnArrow = false;
        
         if ( Close[xctr] == PrevStop ) 
            NewStopLevel = PrevStop;
         else if ( Close[xctr + 1] <= PrevStop && Close[xctr] < PrevStop ) 
             NewStopLevel = MathMin( PrevStop, ( Close[xctr] + DeltaStop ) );
         else if ( Close[xctr + 1] >= PrevStop && Close[xctr] > PrevStop ) 
            NewStopLevel = MathMax( PrevStop, ( Close[xctr] - DeltaStop ) );
         else if ( Close[xctr] > PrevStop ) 
         {
            NewStopLevel = Close[xctr] - DeltaStop;
            DrawUpArrow = true;
         }
         else if ( Close[xctr] < PrevStop ) 
         {
            NewStopLevel = Close[xctr] + DeltaStop;
            DrawDnArrow = true;
         }
        
        TrStopLevel[xctr] = NewStopLevel;
	     UpBuffer[xctr] = EMPTY_VALUE;  
	     DownBuffer[xctr] = EMPTY_VALUE;  
      
        // Can't do the arrows until the bar closes
        if ( xctr > 0 && Time[xctr] > LastArrowTime) 
        {
            if ( DrawUpArrow ) 
            { 
              LastArrowTime = Time[xctr];
              LastArrowSignal = true;
              UpBuffer[xctr] = TrStopLevel[xctr] - ( ArrowDistance * Point ) - 1*Point;
            }
            else if ( DrawDnArrow ) 
            {
              LastArrowTime = Time[xctr];
              LastArrowSignal = false;
              
              DownBuffer[xctr] = TrStopLevel[xctr] + ( 2 * Point ) + ( ArrowDistance * Point ) + 1*Point;
            }
        }
        
        // Do the alerting
        if ( xctr == 1 && LastArrowTime == Time[xctr]) DoAlerts();
         
        // Check to see if wéve closed a bar and redraw the objects
        if ( xctr == 0 && Time[xctr] != CurrentBarTime)  CurrentBarTime = Time[xctr];
    }
            
    return( 0 );
}


//+------------------------------------------------------------------+
//| Gets the next object index so they can be deleted later          |
//+------------------------------------------------------------------+

        

//+------------------------------------------------------------------+
//| Wilders Calculation                                              |
//+------------------------------------------------------------------+
/*double Wilders( double& indBuffer[], int Periods, int shift ) {
    double retval = 0.0;
    retval = iMAOnArray( indBuffer, 0, ( Periods * 2 ) - 1, 0, MODE_EMA, shift );
    return( retval );
}*/
    
//+------------------------------------------------------------------+
//| Delete all the arrow objects                                     |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Handles alerting via sound/email                                 |
//+------------------------------------------------------------------+
void DoAlerts() {
    if ( LastArrowTime > LastAlertBar ) {
        if ( AlertSound ) {
            PlaySound( "alert.wav" );
        }
        
        if ( AlertMail ) {
            int per = Period();
            string perstr = "";
            
            switch( per ) {
                case PERIOD_M1:
                    perstr = "M1";
                    break;
                    
                case PERIOD_M5:
                    perstr = "M5";
                    break;
                    
                case PERIOD_M15:
                    perstr = "M15";
                    break;
                    
                case PERIOD_M30:
                    perstr = "M30";
                    break;
                    
                case PERIOD_H1:
                    perstr = "H1";
                    break;
                    
                case PERIOD_H4:
                    perstr = "H4";
                    break;
                    
                case PERIOD_D1:
                    perstr = "D1";
                    break;
                    
                case PERIOD_W1:
                    perstr = "W1";
                    break;
                    
                case PERIOD_MN1:
                    perstr = "MN1";
                    break;
                    
                default:
                    perstr = "" + per + " Min";
                    break;
            }
                    
            datetime curtime = TimeCurrent();
            string strSignal = "LONG";
            if ( !LastArrowSignal ) {
                strSignal = "SHORT";
            }
            string str_subject = "MT4-SLReverse Alert " + TimeToStr( curtime, TIME_DATE | TIME_SECONDS );
            SendMail( str_subject,
                      "The StopLevelReverse has given a " +
                      strSignal +
                      " signal for pair " +
                      Symbol() +
                      " " + perstr + "." );
        }
        
        LastAlertBar = LastArrowTime;
    }
}
    

//+------------------------------------------------------------------+