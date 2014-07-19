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

- ( BOOL ) isFlipped
    {
    return YES;
    }

- ( void ) drawRect: ( NSRect )_Rect
    {
#if 1   // Concurrent drawing
    dispatch_queue_t defaultGlobalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_queue_t serialQueue = dispatch_queue_create( "individual.TongG.fuckQueue", DISPATCH_QUEUE_CONCURRENT );

    srand( ( unsigned )time( NULL ) );

    NSMutableArray* rectArray = [ NSMutableArray arrayWithCapacity: 10000 ];
    NSSize currentSize = [ self bounds ].size;
    for ( int index = 0; index < 100000; index++ )
        {
        CGFloat randomWidth = ( CGFloat )( rand() % ( NSInteger )currentSize.width );
        CGFloat randomHeight = ( CGFloat )( rand() % ( NSInteger )currentSize.height );

        CGFloat randomX = ( CGFloat )( rand() %20 + 10 );
        CGFloat randomY = ( CGFloat )( rand() %20 + 10 );

        [ rectArray addObject: [ NSValue valueWithRect: NSMakeRect( randomWidth, randomHeight, randomX, randomY ) ] ];
        }

    NSArray* colorArray = @[ [ NSColor grayColor ],  [ NSColor blackColor ]
                           , [ NSColor cyanColor ],   [ NSColor greenColor ]
                           , [ NSColor purpleColor ], [ NSColor orangeColor ]
                           , [ NSColor darkGrayColor ], [ NSColor yellowColor ]
                           ];

    dispatch_async( serialQueue
                  , ^( void )
                    {
                    dispatch_apply( [ rectArray count ], defaultGlobalQueue
                                  , ^( size_t _CurrentIndex )
                                    {
                                    [ self lockFocusIfCanDraw ];
                                    [ NSGraphicsContext saveGraphicsState ];

                                    // The elements type for rectArray is NSValue, so we must invoke rectValue method to out-box the rectangle.
                                    NSRect currentRect = [ [ rectArray objectAtIndex: _CurrentIndex ] rectValue ];

                                    NSColor* currentColor = [ colorArray objectAtIndex: _CurrentIndex % [ colorArray count ] ];

                                    [ currentColor set ];
                                    NSRect tmpRect = NSInsetRect( currentRect, -( CGFloat )_CurrentIndex, -( CGFloat )_CurrentIndex );

                                    NSFrameRectWithWidth( tmpRect, _CurrentIndex );

                                    [ [ NSGraphicsContext currentContext ] flushGraphics ];

                                    [ NSGraphicsContext restoreGraphicsState ];
                                    [ self unlockFocus ];
                                    } );
                    } );
#endif

#if 0   // Serial drawing
    for ( int _CurrentIndex = 0; _CurrentIndex < [ rectArray count ]; _CurrentIndex++ )
        {
        [ NSGraphicsContext saveGraphicsState ];

        // The elements type for rectArray is NSValue, so we must invoke rectValue method to out-box the rectangle.
        NSRect currentRect = [ [ rectArray objectAtIndex: _CurrentIndex ] rectValue ];

        NSColor* currentColor = [ colorArray objectAtIndex: _CurrentIndex % [ colorArray count ] ];

        [ currentColor set ];
        NSRect tmpRect = NSInsetRect( currentRect, -( CGFloat )_CurrentIndex, -( CGFloat )_CurrentIndex );

        NSFrameRectWithWidth( tmpRect, _CurrentIndex );

        [ [ NSGraphicsContext currentContext ] flushGraphics ];

        [ NSGraphicsContext restoreGraphicsState ];
        }
#endif
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