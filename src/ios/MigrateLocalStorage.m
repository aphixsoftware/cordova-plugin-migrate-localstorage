#import "MigrateLocalStorage.h"

@implementation MigrateLocalStorage

- (BOOL) copyFrom:(NSString*)src to:(NSString*)dest
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    // Bail out if source file does not exist
    if (![fileManager fileExistsAtPath:src]) {
        return NO;
    }

    // Bail out if dest file exists
    if ([fileManager fileExistsAtPath:dest]) {
        return NO;
    }

    // create path to dest
    if (![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]) {
        return NO;
    }

    // copy src to dest
    return [fileManager copyItemAtPath:src toPath:dest error:nil];
}

- (void) migrateLocalStorage
{
    NSString *appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cacheFolder;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[appLibraryFolder stringByAppendingPathComponent:@"WebKit/LocalStorage/file__0.localstorage"]]) {
        cacheFolder = [appLibraryFolder stringByAppendingPathComponent:@"WebKit/LocalStorage"];
    } else {
        cacheFolder = [appLibraryFolder stringByAppendingPathComponent:@"Caches"];
    }
    
    NSString *UIWebViewLocalStoragePath = [cacheFolder stringByAppendingPathComponent:@"file__0.localstorage"];
    NSString *WKWebViewLocalStoragePath = [[NSString alloc] initWithString: [appLibraryFolder stringByAppendingPathComponent:@"WebKit"]];
    
#if TARGET_IPHONE_SIMULATOR
    NSString* bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    WKWebViewLocalStoragePath = [WKWebViewLocalStoragePath stringByAppendingPathComponent:bundleIdentifier];
#endif

    
    WKWebViewLocalStoragePath = [WKWebViewLocalStoragePath stringByAppendingPathComponent:@"WebsiteData/LocalStorage/http_localhost_49000.localstorage"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:WKWebViewLocalStoragePath]) {
        NSLog(@"No existing localstorage data found for WKWebView. Migrating data from UIWebView");
        [self copyFrom:UIWebViewLocalStoragePath to:WKWebViewLocalStoragePath];
        [self copyFrom:[UIWebViewLocalStoragePath stringByAppendingString:@"-shm"] to:[WKWebViewLocalStoragePath stringByAppendingString:@"-shm"]];
        [self copyFrom:[UIWebViewLocalStoragePath stringByAppendingString:@"-wal"] to:[WKWebViewLocalStoragePath stringByAppendingString:@"-wal"]];
    }
}

- (void)pluginInitialize
{
    [self migrateLocalStorage];
}


@end
