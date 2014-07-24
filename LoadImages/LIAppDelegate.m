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

#import "LIAppDelegate.h"
#import "LIMainWindowController.h"

// LIAppDelegate class
@implementation LIAppDelegate

@synthesize _mainWindowController;

#pragma mark -
#pragma mark Conforms <NSNibLoading> protocol
- ( void ) awakeFromNib
    {
    self._mainWindowController = [ LIMainWindowController mainWindowController ];

    [ self._mainWindowController showWindow: self ];
    }

- ( void ) applicationDidFinishLaunching: ( NSNotification* )_Notification
    {

    }

- ( IBAction ) drawingPatterns: ( id )_Sender
    {
    [ [ NSNotificationCenter defaultCenter ] postNotificationName: @"TranslateContext"
                                                           object: self ];
    }

- ( IBAction ) testingForColorSpace: ( id )_Sender
    {
    NSColor* calibratedRGBColor = [ NSColor colorWithCalibratedRed: .4
                                                             green: .76
                                                              blue: .89
                                                             alpha: .98 ];

    NSColor* deviceRGBColor = [ NSColor colorWithDeviceRed: .4
                                                     green: .76
                                                      blue: .89
                                                     alpha: .98 ];

    NSColor* deviceCMYKColor = [ NSColor colorWithDeviceCyan: .4
                                                     magenta: .5
                                                      yellow: .8
                                                       black: .3
                                                       alpha: .6 ];

    NSColor* calibratedHSBColor = [ NSColor colorWithCalibratedHue: .9
                                                        saturation: .8
                                                        brightness: .5
                                                             alpha: 1.f ];
    @try {
        printComponentsValue( [ NSColor knobColor ] );
        } @catch ( NSException* _Ex )
            { NSLog( @"Catched Exception: %@", [ _Ex reason ] ); }
    }

- ( NSColor* ) convertColor: ( NSColor* )_Color
                   fallInto: ( NSColorSpace* )_ColorSpace
    {
    if ( !_Color )
        return nil;

    NSColor* convertedColor = nil;

    if ( [ _Color colorSpace ] == _ColorSpace )
        convertedColor = [ _Color copy ];
    else
        convertedColor = [ _Color colorUsingColorSpace: _ColorSpace ];

    return convertedColor;
    }

void printComponentsValue( NSColor* _ColorObj )
    {
    NSInteger numberOfComponents = [ _ColorObj numberOfComponents ];
    CGFloat* components = malloc( sizeof( CGFloat ) * numberOfComponents );
    [ _ColorObj getComponents: components ];

    NSColorSpace* colorSpaceForSpecifiedColor = [ _ColorObj colorSpace ];
    if ( colorSpaceForSpecifiedColor == [ NSColorSpace deviceRGBColorSpace ] )
        NSLog( @"Device RGB space:" );
    else if ( colorSpaceForSpecifiedColor == [ NSColorSpace deviceCMYKColorSpace ] )
        NSLog( @"Device CMYK space:" );
    else if ( colorSpaceForSpecifiedColor == [ NSColorSpace genericRGBColorSpace ] )
        NSLog( @"Calibrated RGB space:" );
    else if ( colorSpaceForSpecifiedColor == [ NSColorSpace genericCMYKColorSpace ] )
        NSLog( @"Calibrated CMYK space:" );

    for ( int index = 0; index < numberOfComponents; index++ )
        NSLog( @"Component Value: %g", components[ index ] );

    NSLog( @"\n" );

    free( components );
    }

#pragma mark Testings for NSImage, NSImageRep along with its subclass
- ( IBAction ) testingForImageRef: ( id )_Sender
    {
    NSOpenPanel* openPanel = [ NSOpenPanel openPanel ];

    [ openPanel beginSheetModalForWindow: [ self._mainWindowController window ]
                       completionHandler:
        ^( NSInteger _Result )
            {
            if ( _Result == NSFileHandlingPanelOKButton )
                {
                NSArray* imageReps = [ NSImageRep imageRepsWithContentsOfURL: [ openPanel URL ] ];

                NSLog( @"ImageReps: %@", imageReps );
                }
            } ];

    }

@end // LIAppDelegate

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