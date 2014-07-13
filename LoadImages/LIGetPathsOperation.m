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

// LIGetPathsOperation class
@implementation LIGetPathsOperation

@synthesize _rootURL;
@synthesize _operationQueue;

@synthesize _catchedExInMainTask;

#pragma mark Initializer(s)
+ ( id ) opetationWith: ( NSURL* )_URL
    {
    return [ [ [ [ self class ] alloc ] initWithURL: _URL ] autorelease ];
    }

- ( id ) initWithURL: ( NSURL* )_URL
    {
    if ( self = [ super init ] )
        self->_rootURL = _URL;

    return self;
    }

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
            for ( NSURL* url in dirEnumor )
                {
                if ( [ self isCancelled ] )
                    {
                    NSLog( @"# User cancelled this operation #" );
                    break;
                    }

                NSLog( @"%@", url );
                }
            }
        } @catch ( NSException* _Ex )
            {
            @synchronized ( self )
                {
                if ( !self._catchedExInMainTask )
                    self->_catchedExInMainTask = [ NSMutableArray array ];

                [ self->_catchedExInMainTask addObject: _Ex ];
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