#import <Foundation/Foundation.h>

//#define KUDAN_SERVER

//#ifndef KUDAN_SERVER
//static NSString * const kJSONURL = @"https://tf.sanmaoyou.com/kukan.json";
//#else
//static NSString * const kJSONURL = @"https://api.kudan.eu/CMS/JSON/test.json";
//#endif
static NSString * const kJSONURL = @"https://tf.sanmaoyou.com/kukan.json";

@protocol CMSDownloadProgress <NSObject>
@required
- (void)updateProgressView:(NSNumber *)percentage;

@end


@interface CMSNetworking : NSObject <NSURLConnectionDataDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, weak) id <CMSDownloadProgress> progressDelegate;

/// Returns YES if it was possible to check the remote server and download updated content
- (BOOL)downloadFiles;

@end
