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
    {
    BOOL _isFinished;
    BOOL _isExecuting;
    }

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
        {
        self._rootURL = _URL;

        self->_isFinished = NO;
        self->_isExecuting = NO;
        }

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

#pragma mark Part for implementation of concurrent operation
#if 1
- ( void ) start
    {
    if ( [ self isCancelled ] )
        {
        [ self willChangeValueForKey: @"_isFinished" ];
            self->_isFinished = YES;
        [ self didChangeValueForKey: @"_isFinished" ];

        return;
        }

    [ self willChangeValueForKey: @"_isExecuting" ];
        [ NSThread detachNewThreadSelector: @selector( main ) toTarget: self withObject: nil ];
        self->_isExecuting = YES;
    [ self didChangeValueForKey: @"_isExecuting" ];
    }

- ( BOOL ) isConcurrent
    {
    return NO;
    }

- ( BOOL ) isFinished
    {
    return self->_isFinished;
    }

- ( BOOL ) isExecuting
    {
    return self->_isExecuting;
    }

- ( BOOL ) isReady
    {
    return [ super isReady ];
    }

- ( void ) completeOperation
    {
    [ self willChangeValueForKey: @"_isExecuting" ];
    [ self willChangeValueForKey: @"_isFinished" ];

        self->_isExecuting = NO;
        self->_isFinished = YES;

    [ self didChangeValueForKey: @"_isExecuting" ];
    [ self didChangeValueForKey: @"_isFinished" ];
    }
#endif
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
                NSString* imagePath = [ imageURL absoluteString ];

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

        // Notify the observers that our operation is now finished with its task
        // regardless of whether the operation is cancelled or not.
        [ self completeOperation ];

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