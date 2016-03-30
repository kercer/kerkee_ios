//
//  KCDirWatcher.m
//  kerkee
//
//  Object used to monitor the contents of a given directory
//  by using "kqueue": a kernel event notification mechanism.
//
//  Created by zihong on 16/3/30.
//  Copyright (c) 2016年 zihong. All rights reserved.
//

#import "KCDirWatcher.h"

#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <fcntl.h>
#include <unistd.h>

#import <CoreFoundation/CoreFoundation.h>

@interface KCDirWatcher ()
{
    id <KCDirWatcherDelegate> __weak delegate;
    int m_dirFD;
    int m_kq;
    CFFileDescriptorRef m_dirKQRef;
}
@end


#pragma mark -

@implementation KCDirWatcher

@synthesize delegate;

- (instancetype)init
{
	self = [super init];
	delegate = NULL;

	m_dirFD = -1;
    m_kq = -1;
	m_dirKQRef = NULL;
	
	return self;
}

- (void)dealloc
{
	[self stop];
}

+ (KCDirWatcher *)watchDirWithPath:(NSString *)aWatchPath delegate:(id)aWatchDelegate
{
	KCDirWatcher *retVal = NULL;
	if ((aWatchDelegate != NULL) && (aWatchPath != NULL))
	{
		KCDirWatcher *tempManager = [[KCDirWatcher alloc] init];
		tempManager.delegate = aWatchDelegate;
		if ([tempManager startMonitoringDirectory: aWatchPath])
		{
			// Everything appears to be in order, so return the KCDirWatcher.
			// Otherwise we'll fall through and return NULL.
			retVal = tempManager;
		}
	}
	return retVal;
}

- (void)stop
{
	if (m_dirKQRef != NULL)
	{
		CFFileDescriptorInvalidate(m_dirKQRef);
		CFRelease(m_dirKQRef);
		m_dirKQRef = NULL;
		// We don't need to close the kq, CFFileDescriptorInvalidate closed it instead.
		// Change the value so no one thinks it's still live.
		m_kq = -1;
	}
	
	if(m_dirFD != -1)
	{
		close(m_dirFD);
		m_dirFD = -1;
	}
}

- (void)kqueueFired
{
    assert(m_kq >= 0);

    struct kevent   event;
    struct timespec timeout = {0, 0};
    int             eventCount;
	
    eventCount = kevent(m_kq, NULL, 0, &event, 1, &timeout);
    assert((eventCount >= 0) && (eventCount < 2));
    
	// call our delegate of the directory change
    [delegate directoryDidChange:self];

    CFFileDescriptorEnableCallBacks(m_dirKQRef, kCFFileDescriptorReadCallBack);
}

static void KQCallback(CFFileDescriptorRef kqRef, CFOptionFlags callBackTypes, void *info)
{
    KCDirWatcher *obj;
	
    obj = (__bridge KCDirWatcher *)info;
    assert([obj isKindOfClass:[KCDirWatcher class]]);
    assert(kqRef == obj->m_dirKQRef);
    assert(callBackTypes == kCFFileDescriptorReadCallBack);
	
    [obj kqueueFired];
}

- (BOOL)startMonitoringDirectory:(NSString *)dirPath
{
	// Double initializing is not going to work...
	if ((m_dirKQRef == NULL) && (m_dirFD == -1) && (m_kq == -1))
	{
		// Open the directory we're going to watch
		m_dirFD = open([dirPath fileSystemRepresentation], O_EVTONLY);
		if (m_dirFD >= 0)
		{
			// Create a kqueue for our event messages...
			m_kq = kqueue();
			if (m_kq >= 0)
			{
				struct kevent eventToAdd;
				eventToAdd.ident  = m_dirFD;
				eventToAdd.filter = EVFILT_VNODE;
				eventToAdd.flags  = EV_ADD | EV_CLEAR;
				eventToAdd.fflags = NOTE_WRITE;
				eventToAdd.data   = 0;
				eventToAdd.udata  = NULL;
				
				int errNum = kevent(m_kq, &eventToAdd, 1, NULL, 0, NULL);
				if (errNum == 0)
				{
					CFFileDescriptorContext context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
					CFRunLoopSourceRef      rls;

					// Passing true in the third argument so CFFileDescriptorInvalidate will close kq.
					m_dirKQRef = CFFileDescriptorCreate(NULL, m_kq, true, KQCallback, &context);
					if (m_dirKQRef != NULL)
					{
						rls = CFFileDescriptorCreateRunLoopSource(NULL, m_dirKQRef, 0);
						if (rls != NULL)
						{
							CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
							CFRelease(rls);
							CFFileDescriptorEnableCallBacks(m_dirKQRef, kCFFileDescriptorReadCallBack);
							
							// If everything worked, return early and bypass shutting things down
							return YES;
						}
						// Couldn't create a runloop source, invalidate and release the CFFileDescriptorRef
						CFFileDescriptorInvalidate(m_dirKQRef);
                        CFRelease(m_dirKQRef);
						m_dirKQRef = NULL;
					}
				}
				// kq is active, but something failed, close the handle...
				close(m_kq);
				m_kq = -1;
			}
			// file handle is open, but something failed, close the handle...
			close(m_dirFD);
			m_dirFD = -1;
		}
	}
	return NO;
}

@end
