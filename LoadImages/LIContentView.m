///:
/*****************************************************************************
 **                                                                         **
 **                               .======.                                  **
 **                               | INRI |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                      .========'      '========.                         **
 **                      |   _      xxxx      _   |                         **
 **                      |  /_;-.__ / _\  _.-;_\  |                         **
 **                      |     `-._`'`_/'`.-'     |                         **
 **                      '========.`\   /`========'                         **
 **                               | |  / |                                  **
 **                               |/-.(  |                                  **
 **                               |\_._\ |                                  **
 **                               | \ \`;|                                  **
 **                               |  > |/|                                  **
 **                               | / // |                                  **
 **                               | |//  |                                  **
 **                               | \(\  |                                  **
 **                               |  ``  |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                   \\    _  _\\| \//  |//_   _ \// _                     **
 **                  ^ `^`^ ^`` `^ ^` ``^^`  `^^` `^ `^                     **
 **                                                                         **
 **                       Copyright (c) 2014 Tong G.                        **
 **                          ALL RIGHTS RESERVED.                           **
 **                                                                         **
 ****************************************************************************/

#import "LIContentView.h"

// LIContentView class
@implementation LIContentView

@synthesize _mouseDownCount;
@synthesize _bezierPath;

- ( void ) awakeFromNib
    {
    self._mouseDownCount = 0;
    self._bezierPath = [ NSBezierPath bezierPath ];

    [ [ NSNotificationCenter defaultCenter ] addObserver: self
                                                selector: @selector( handleDrawingPatternsNotif: )
                                                    name: @"TranslateContext"
                                                  object: nil ];
    }

- ( void ) dealloc
    {
    [ [ NSNotificationCenter defaultCenter ] removeObserver: self ];

    [ super dealloc ];
    }

- ( BOOL ) isFlipped
    {
    return YES;
    }

//- ( void ) drawRect: ( NSRect )_Rect
//    {
//
//    }

- ( void ) handleDrawingPatternsNotif: ( NSNotification* )_Notif
    {
    NSColor* RGBColor = [ NSColor colorWithCalibratedRed: 124.f / 255.f
                                                green: 113.f / 255.f
                                                 blue: 183.f / 255.f
                                                alpha: 0.9 ];

    NSColor* CMYKColor = [ NSColor colorWithDeviceCyan: 0.6324f
                                               magenta: 0.1843f
                                                yellow: 0.1571f
                                                 black: 0.0221f
                                                 alpha: 1.f ];

    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 )
                  , ^( void )
                    {
                    [ self lockFocusIfCanDraw ];

                    [ NSGraphicsContext saveGraphicsState ];
                    NSRect customClipRectOne = NSMakeRect( 50, 20, 100, 250 );
                    NSRect customClipRectTwo = NSMakeRect( 500, 5, 100, 100 );
                    NSRect customClipRectThree = NSMakeRect( 500, 150, 100, 100 );
                    NSRect customClipRectFour = NSMakeRect( 250, 150, 70, 100 );

                    NSBezierPath* customClipRegionOne = [ NSBezierPath bezierPathWithRect: customClipRectOne ];
                    [ customClipRegionOne appendBezierPathWithRect: customClipRectTwo ];
                    [ customClipRegionOne appendBezierPathWithOvalInRect: customClipRectThree ];
                    [ customClipRegionOne appendBezierPathWithOvalInRect: customClipRectFour ];

                    NSAffineTransform* xForm = [ NSAffineTransform transform ];
                    NSAffineTransformStruct transformStruct = { .8, 0, 0, .8, 160, 54 };
                    [ xForm setTransformStruct: transformStruct ];
//                    [ xForm translateXBy: 160 yBy: 54 ];
//                    [ xForm scaleBy: .8f ];
//                    [ xForm rotateByDegrees: 45 ];

                    [ xForm concat ];

                    NSFrameRect( customClipRectOne );
                    NSFrameRect( customClipRectTwo );
                    NSFrameRect( customClipRectThree );
                    NSFrameRect( customClipRectFour );

                    CGFloat rectWidth = 100.f;
                    CGFloat rectHeight = 50.f;
                    CGFloat widthGap = 20.f;
                    CGFloat heightGap = 30.f;
                    NSRect drawingArea = NSMakeRect( self.frame.origin.x + widthGap, self.frame.origin.y + heightGap
                                                   , self.frame.size.width - self.frame.origin.x * 2
                                                   , self.frame.size.height - self.frame.origin.y * 2 );


                    NSRect lastRect = NSMakeRect( drawingArea.origin.x, drawingArea.origin.y, rectWidth, rectHeight );
                    int fuckVal = 0;

                    for ( size_t index = 0; index < 50; index ++ )
                        {
                        [ [ NSGraphicsContext currentContext ] saveGraphicsState ];

                        NSRect originalRect = lastRect;
                        originalRect.origin.x = ( lastRect.size.width + widthGap ) * fuckVal++ + widthGap;
                        originalRect.origin.y = lastRect.origin.y;

                        if ( ( originalRect.origin.x + originalRect.size.width ) > drawingArea.size.width )
                            {
                            int static transboundaryCount = 1;
                            fuckVal = 0;
                            originalRect.origin.x = drawingArea.origin.x;
                            originalRect.origin.y = heightGap + ( heightGap + originalRect.size.height ) * transboundaryCount++;
                            }

                        NSBezierPath* roundedRectPath = [ NSBezierPath bezierPathWithRoundedRect: originalRect xRadius: index yRadius: index ];
                        [ roundedRectPath setLineWidth: 10 ];
                        [ CMYKColor set ];
                        [ roundedRectPath stroke ];

                        [ RGBColor set ];
                        [ roundedRectPath fill ];

                        lastRect = originalRect;

                        [ [ NSGraphicsContext currentContext ] flushGraphics ];
                        [ [ NSGraphicsContext currentContext ] restoreGraphicsState ];
                        }

                    [ NSGraphicsContext restoreGraphicsState ];
                    [ self unlockFocus ];
                    } );
    }

- ( void ) mouseDown: ( NSEvent* )_Event
    {
    NSPoint downPoint = [ self convertPoint: [ _Event locationInWindow ] fromView: nil ];

    if ( self._mouseDownCount < 4 )
        {
        self._mouseDownCount++;

        if ( self._mouseDownCount == 1 )
            [ self._bezierPath moveToPoint: downPoint ];
        else
            [ self._bezierPath lineToPoint: downPoint ];
        }
    else
        {
        [ self._bezierPath stroke ];

        self._mouseDownCount = 0;

        [ self._bezierPath removeAllPoints ];
        }
    }

@end // LIContentView

/////////////////////////////////////////////////////////////////////////////

/****************************************************************************
 **                                                                        **
 **      _________                                      _______            **
 **     |___   ___|                                   / ______ \           **
 **         | |     _______   _______   _______      | /      |_|          **
 **         | |    ||     || ||     || ||     ||     | |    _ __           **
 **         | |    ||     || ||     || ||     ||     | |   |__  \          **
 **         | |    ||     || ||     || ||     ||     | \_ _ __| |  _       **
 **         |_|    ||_____|| ||     || ||_____||      \________/  |_|      **
 **                                           ||                           **
 **                                    ||_____||                           **
 **                                                                        **
 ***************************************************************************/
///:~