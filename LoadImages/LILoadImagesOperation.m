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

#import "LILoadImagesOperation.h"

// Keys in the userInfo of NSNotification object
NSString* const LILoadImageOperationUserDataError = @"error";
NSString* const LILoadImageOperationUserDataFileInfo = @"fileInfo";

// Keys in the fileInfo dictionary
NSString* const LILoadImageOperationFileInfoNameKey = @"name";
NSString* const LILoadImageOperationFileInfoPathKey = @"path";
NSString* const LILoadImageOperationFileInfoModifiedDateKey = @"modifiedDate";
NSString* const LILoadImageOperationFileInfoSizeKey = @"size";

// Notification name
NSString* const LILoadImageOperationLoadImageWillFinish = @"load image will finish";
NSString* const LILoadImageOperationLoadImageDidFinish = @"load image did finish";

// LILoadImagesOperation class
@implementation LILoadImagesOperation

@synthesize _rootURL;

@synthesize _catchedExInMainTask;

#pragma mark Initializer(s)
+ ( id ) opetationWith: ( NSURL* )_URL
    {
    return [ [ [ [ self class ] alloc ] initWithURL: _URL ] autorelease ];
    }

- ( id ) initWithURL: ( NSURL* )_URL
    {
    if ( self = [ super init ] )
        self._rootURL = _URL;

    return self;
    }

#pragma mark Misc
- ( BOOL ) isImageFile: ( NSURL* )_FileForTesting
    {
    BOOL isImageFile = NO;
    NSString* UTLString = nil;
    NSError* error = nil;

    BOOL res = [ _FileForTesting getResourceValue: &UTLString
                                           forKey: NSURLTypeIdentifierKey
                                            error: &error ];
    if ( res && UTLString )
        isImageFile = UTTypeConformsTo( ( __bridge CFStringRef )UTLString, kUTTypeImage );

    return isImageFile;
    }

#pragma mark Overrides for main task
- ( void ) main
    {
    @try {
        if ( ![ self isCancelled ] )
            {
            if ( [ self isImageFile: self._rootURL ] )
                {
                // Post a notification before loading the image
                if ( ![ self isCancelled ] )
                    [ [ NSNotificationCenter defaultCenter ] postNotificationName: LILoadImageOperationLoadImageWillFinish
                                                                           object: self
                                                                         userInfo: nil ];

                NSURL* imageURL = self._rootURL;

                NSString* iamgeName = [ [ imageURL URLByDeletingPathExtension ] lastPathComponent ];
                NSString* imagePath = [ imageURL path ];

                NSDate* modifiedDate = nil;
                [ imageURL getResourceValue: &modifiedDate forKey: NSURLContentModificationDateKey error: nil ];

                NSNumber* imageSize = @0;
                [ imageURL getResourceValue: &imageSize forKey: NSURLFileSizeKey error: nil ];

                // The entry in userInfo will be added to the data source for table view
                NSDictionary* userInfo = @{ LILoadImageOperationFileInfoNameKey : iamgeName
                                          , LILoadImageOperationFileInfoPathKey : imagePath
                                          , LILoadImageOperationFileInfoModifiedDateKey : modifiedDate
                                          , LILoadImageOperationFileInfoSizeKey : [ NSNumber numberWithFloat: imageSize.floatValue / 1024 ]
                                          };

                // Post a notification if the image has been loaded successfully
                if ( ![ self isCancelled ] )
                    [ [ NSNotificationCenter defaultCenter ] postNotificationName: LILoadImageOperationLoadImageDidFinish
                                                                           object: self
                                                                         userInfo: userInfo ];
                }
            }
        } @catch ( NSException* _Ex )
            {
            @synchronized( self )
                {
                if ( !self._catchedExInMainTask )
                    self._catchedExInMainTask = [ NSMutableArray array ];

                [ self._catchedExInMainTask addObject: _Ex ];
                }
            }
    }

@end // LILoadImagesOperation

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