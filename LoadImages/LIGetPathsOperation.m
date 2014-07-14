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

#import "LIGetPathsOperation.h"
#import "LILoadImagesOperation.h"

// LIGetPathsOperation class
@implementation LIGetPathsOperation

@synthesize _isExecuting;
@synthesize _isFinished;

@synthesize _rootURL;
@synthesize _operationQueue;

@synthesize _catchedExInMainTask;

@synthesize _cachedPaths;

#pragma mark Initializer(s)
+ ( id ) operationWithURL: ( NSURL* )_URL
    {
    return [ [ [ [ self class ] alloc ] initWithURL: _URL ] autorelease ];
    }

- ( id ) initWithURL: ( NSURL* )_URL
    {
    if ( self = [ super init ] )
        {
        self._rootURL = _URL;
        self._operationQueue = [ [ [ NSOperationQueue alloc ] init ] autorelease ];
        [ self._operationQueue setMaxConcurrentOperationCount: NSOperationQueueDefaultMaxConcurrentOperationCount ];

        self._cachedPaths = [ NSMutableArray arrayWithCapacity: 10 ];

        self->_isExecuting = NO;
        self->_isFinished = NO;
        }

    return self;
    }

- ( void ) dealloc
    {
    [ super dealloc ];
    }

#pragma mark Part for implementation of concurrent operation
#if 1
- ( void ) start
    {
    // Always check for cancellation before launching the task.
    if ( [ self isCancelled ] )
        {
        [ self willChangeValueForKey: @"_isFinished" ];
            self->_isFinished = YES;
        [ self didChangeValueForKey: @"_isFinished" ];

        return;
        }

    // If the operation is not canceled, begin executing the task.
    [ self willChangeValueForKey: @"_isExecuting" ];
        [ NSThread detachNewThreadSelector: @selector( main ) toTarget: self withObject: nil ];
        self->_isExecuting = YES;
    [ self didChangeValueForKey: @"_isExecuting" ];

    #if 1   // TESTME:
    [ self setCompletionBlock:
        ^( void )
            {
            [ self willChangeValueForKey: @"_isFinished" ];
            [ self willChangeValueForKey: @"_isExecuting" ];

                self->_isFinished = YES;
                self->_isExecuting = NO;

            [ self didChangeValueForKey: @"_isFinished" ];
            [ self didChangeValueForKey: @"_isExecuting" ];
            } ];
    #endif
    }

- ( BOOL ) isConcurrent
    {
    return NO;
    }

- ( BOOL ) isExecuting
    {
    return self->_isExecuting;
    }

- ( BOOL ) isFinished
    {
    return self->_isFinished;
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

/* Because of the extra constraint in open panel, ( [ openPanel setCanChooseFiles: NO ] )
 * self._url would never be a file name, it's always a dir name.
 */
- ( void ) main
    {
    @try {
        if ( ![ self isCancelled ] )
            {
            NSFileManager* fileManager = [ NSFileManager defaultManager ];

            /* 1. Ignores hidden files
             * 2. Ignores package descendents */
            NSDirectoryEnumerator* dirEnumor = [ fileManager enumeratorAtURL: self._rootURL
                                                  includingPropertiesForKeys: nil
                                                                     options: NSDirectoryEnumerationSkipsHiddenFiles
                                                                                | NSDirectoryEnumerationSkipsPackageDescendants
                                                                errorHandler: nil ];
            NSInteger cacheCount = 10;
            for ( NSURL* url in dirEnumor )
                {
                if ( [ self isCancelled ] )
                    {
                    NSLog( @"# User cancelled this operation #" );
                    break;
                    }

                if ( cacheCount-- > 0 )
                    [ self._cachedPaths addObject: url ];
                else
                    {
                    LILoadImagesOperation* loadImageOperation =
                        [ LILoadImagesOperation operationWithURLs: self._cachedPaths ];

                    [ loadImageOperation setQueuePriority: NSOperationQueuePriorityVeryHigh ];
                    [ self._operationQueue addOperations: @[ loadImageOperation ] waitUntilFinished: NO ];

                    cacheCount = 10;

                    [ self._cachedPaths removeAllObjects ];
                    }
                }
            }

        // Notify the observers that our operation is now finished with its work,
        // regardless of whether the operation is cancelled or not.
        [ self completeOperation ];

        } @catch ( NSException* _Ex )
            {
            @synchronized ( self )
                {
                if ( !self._catchedExInMainTask )
                    self._catchedExInMainTask = [ NSMutableArray array ];

                [ self._catchedExInMainTask addObject: _Ex ];
                }
            }
    }

@end // LIGetPathsOperation

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