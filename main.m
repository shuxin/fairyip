//
//  fairyip.m
//  fairy ip
//
//  Created by fairytale on 12-6-9.
//  Copyright (c) 2012年 FT. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h> 
// time.c
#include <sys/socket.h>

#include <sys/time.h>
//#include "/System/Library/Frameworks/Kernel.framework/Headers/sys/sysproto.h"
//#include <sys/ioccom.h>
//#include <sys/filio.h>

//#include <sys/sysproto.h>
#include <stdarg.h>
#include <dlfcn.h>
//#include <NSString.h>


//#include <stdio.h>
#include <unistd.h>
#include <dlfcn.h>
#include <time.h>



#import <objc/objc.h>
#import <objc/runtime.h>

#import <Foundation/NSObjCRuntime.h>
//#import <Foundation/NSCFString.h>

#import <Foundation/NSDictionary.h>
#import <Foundation/NSKeyValueCoding.h>
#import <Foundation/Foundation.h>


/*

typedef void (*Module_Method__IMP)(UIWebView* self, SEL _cmd, NSURLRequest *request);
 
static Module_Method__IMP Module_Method__loadRequest;
 
void Module_Method__loadRequest_hooked(UIWebView* self, SEL _cmd, NSURLRequest *request) {
 
    original_UIWebView_loadRequest(self, _cmd, request);
 
    // TODO:
 
}
*/




struct in_addr {
    union {
        struct { u_char s_b1,s_b2,s_b3,s_b4; } S_un_b;
        struct { u_short s_w1,s_w2; } S_un_w;
        u_long S_addr;
    } S_un;
};

struct sockaddr_in{
    short sin_family;
    unsigned short sin_port;
    struct in_addr sin_addr;
    char sin_zero[8];
};

NSMutableDictionary *qqUinWanIp;// =  [[NSMutableDictionary  alloc ]init];
NSMutableDictionary *qqUinLanIp;// =  [[NSMutableDictionary  alloc ]init];
NSMutableDictionary *qqUinWTime;// =  [[NSMutableDictionary  alloc ]init];
NSMutableDictionary *qqUinLTime;// =  [[NSMutableDictionary  alloc ]init];
NSMutableDictionary *ipAddrCache;// =  [[NSMutableDictionary  alloc ]init];
NSMutableDictionary *ipToQqCache;// =  [[NSMutableDictionary  alloc ]init];
NSMutableDictionary *ipTimeCache;// =  [[NSMutableDictionary  alloc ]init];
unsigned long dictflag=0;
NSMutableArray *qqUinGotAddrList;
int qqUinGotAddrFlag = 0;
NSLock *qqUinGotAddrLock;


unsigned long exTime1=0;
unsigned long exTime2=0;
unsigned long exTime0=0;
unsigned long exTimea=0;
unsigned long exWanIP=0;
unsigned long exLanIP=0;
unsigned long exQQUin=0;



unsigned long my_hooked_objc_msgSend = 0;
unsigned long my_hooked_send = 0;
unsigned long my_hooked_sendto = 0;

ssize_t (*real_send)(int, const void*, size_t, int);
ssize_t (*real_sendto)(int, const void*, size_t, int, const struct sockaddr *, socklen_t);
unsigned long real_objc_msgSend;

unsigned long myMQAIOManagerClass = 0;
unsigned long myMQAIOWindowControllerClass = 0;
//unsigned long myMQAIOUserMessageManagerClass = 0;

int tryFindCountMQAIOManager = 1;
int tryFindCountMQAIOWindowController = 1;

int flagCanAddTips = 0;
int flagCanShakeWindow = 0;

char * myCharMQAIOManager = "MQAIOManager"; //ok
char * myCharMQAIOWindowController = "MQAIOWindowController"; //ok
//char * myCharMQAIOUserMessageManager = "MQAIOUserMessageManager"; //bad

unsigned long myaddTiptoTarget = 0;
unsigned long myaddTiptoTargetchatType = 0;
unsigned long myaddTipwithUin = 0;
unsigned long myaddTipwithUinchatType = 0;
unsigned long mysharedInstance= 0;
unsigned long mychatTypeOfUin = 0;
unsigned long myshakewindow = 0;

char * myCharaddTiptoTarget = "addTip:toTarget:";
char * myCharaddTiptoTargetchatType = "addTip:toTarget:chatType:";
char * myCharaddTipwithUin = "addTip:withUin:";
char * myCharaddTipwithUinchatType = "addTip:withUin:chatType:";
char * myCharsharedInstance = "sharedInstance";
char * myCharchatTypeOfUin = "chatTypeOfUin:";

int addTipsToQqByFairyTale(unsigned long qq, unsigned long tips){
	if(flagCanAddTips == 1){
		void * mythismodule = objc_msgSend(myMQAIOManagerClass,mysharedInstance);
		objc_msgSend(mythismodule,myaddTiptoTarget,tips,qq);		
		return 1;
	}else if (flagCanAddTips == 2){
		void * mythismodule = objc_msgSend(myMQAIOManagerClass,mysharedInstance);
		int mychattype = objc_msgSend(mythismodule,mychatTypeOfUin,qq);
		objc_msgSend(mythismodule,myaddTiptoTargetchatType,tips,qq,mychattype);
		return 1;
	}else{
		return 0;	
	}
}

int addIpTipsToQqByFairyTale(unsigned long qq, unsigned long wanip, unsigned long lanip,void * ipstring){
	if(qq > 0){
		if(wanip>0){
			if (ipstring != 0){
				if (lanip != 0){
//fprintf(stderr,"PRINT: addr wan lan \n");
					NSString *ipinfostr = [[NSString alloc] initWithString:[NSString stringWithFormat:@"ADDR:%@\nWAN[%s]LAN[%d.%d.%d.%d]", ipstring,
					inet_ntoa(wanip),(lanip & 0x000000ff),(lanip & 0x0000ff00)>>8,(lanip & 0x00ff0000)>>16,(lanip & 0xff000000)>>24]];
//					inet_ntoa(wanip),(lanip & 0xff000000)>>24,(lanip & 0x00ff0000)>>16,(lanip & 0x0000ff00)>>8,(lanip & 0x000000ff)]];
					if (addTipsToQqByFairyTale(qq,ipinfostr)!=0){
						exTime0=time(NULL);
						[qqUinLTime setObject:[NSNumber numberWithUnsignedInt:exTime0] forKey:[NSNumber numberWithUnsignedInt:qq]];
						[qqUinWTime setObject:[NSNumber numberWithUnsignedInt:exTime0] forKey:[NSNumber numberWithUnsignedInt:qq]];
					}
					[ipinfostr release];
				}else{
//fprintf(stderr,"PRINT: addr wan ... \n");
					NSString *ipinfostr = [[NSString alloc] initWithString:[NSString stringWithFormat:@"ADDR:%@\nWAN[%s]...", ipstring,inet_ntoa(wanip)]];
					if (addTipsToQqByFairyTale(qq,ipinfostr)!=0){
						exTime0=time(NULL);
						[qqUinWTime setObject:[NSNumber numberWithUnsignedInt:exTime0] forKey:[NSNumber numberWithUnsignedInt:qq]];
					}
					[ipinfostr release];
				}
			} else {
//fprintf(stderr,"PRINT: .... wan ... \n");
				NSString *ipinfostr = [[NSString alloc] initWithString:[NSString stringWithFormat:@"WAN IP[%s]",inet_ntoa(wanip)]];
				if (addTipsToQqByFairyTale(qq,ipinfostr)!=0){
					exTime0=time(NULL);
					[qqUinWTime setObject:[NSNumber numberWithUnsignedInt:exTime0] forKey:[NSNumber numberWithUnsignedInt:qq]];
				}
				[ipinfostr release];
        	}
        }else if(lanip!=0){
//fprintf(stderr,"PRINT: .... ... lan \n");
			NSString *ipinfostr = [[NSString alloc] initWithString:[NSString stringWithFormat:@"LAN IP[%s]",inet_ntoa(lanip)]];
			if (addTipsToQqByFairyTale(qq,ipinfostr)!=0){
				exTimea=time(NULL);
				[qqUinLTime setObject:[NSNumber numberWithUnsignedInt:exTimea] forKey:[NSNumber numberWithUnsignedInt:qq]];
			}
			[ipinfostr release];
        }
	}
	return 0;
}

int addQqIpTipsToQqByFairyTale(unsigned long qq){
	if(qq > 0){
        unsigned long wanip = [[qqUinWanIp objectForKey:[NSNumber numberWithUnsignedInt:qq]] unsignedIntValue];
        unsigned long lanip = [[qqUinLanIp objectForKey:[NSNumber numberWithUnsignedInt:qq]] unsignedIntValue];
        if([ipAddrCache objectForKey:[NSNumber numberWithUnsignedInt:wanip]]) {
            NSString *ipstring = [ipAddrCache objectForKey:[NSNumber numberWithUnsignedInt:wanip]];
            addIpTipsToQqByFairyTale(qq, wanip, lanip, ipstring);
            return 1;
        }
    }else{
        return 0;
    }
	return 0;
}

////////////////////////////////////////////////////////////////////////////////////////
/*
    @interface URLOperation : NSOperation  
    {  
        NSURLRequest*  _request;  
        NSURLConnection* _connection;  
        NSMutableData* _data;  
        //构建gb2312的encoding  
        NSStringEncoding enc;  
    }  
    - (id)initWithURLString:(NSString *)url;  
    @property (readonly) NSData *data;  
    @end 



    @implementation URLOperation  
    @synthesize data=_data;  
    - (id)initWithURLString:(NSString *)url {  
        if (self = [self init]) {  
            NSLog(@"%@",url);  
            _request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url  
            //构建gb2312的encoding  
            enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);  
            _data = [[NSMutableData data] retain];  
        }  
        return self;  
    }  
    - (void)dealloc {  
        [_request release],_request=nil;  
        [_data release],_data=nil;  
        [_connection release],_connection=nil;  
        [super dealloc];  
    }  
    // 如果不重载下面的函数，异步方式调用会出错  
    //- (BOOL)isConcurrent {  //如果采用并发，就不要使用queue，add5次后会发生运行错误
    //  return YES;//返回yes表示支持异步调用，否则为支持同步调用  
    //} 


    // 开始处理-本类的主方法  
    - (void)start {  
        if (![self isCancelled]) {  
            NSLog(@"start operation");  
            // 以异步方式处理事件，并设置代理  
            _connection=[[NSURLConnection connectionWithRequest:_request delegate:self]retain];  
            //下面建立一个循环直到连接终止，使线程不离开主方法，否则connection的delegate方法不会被调用,因为主方法结束对象的生命周期即终止  
            //这个问题参考 http://www.cocoabuilder.com/archive/cocoa/279826-nsurlrequest-and-nsoperationqueue.html  
            while(_connection != nil) {  
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];     
            }  
        }  
    } 

    #pragma mark NSURLConnection delegate Method  
    // 接收到数据（增量）时  
    - (void)connection:(NSURLConnection*)connection  
        didReceiveData:(NSData*)data {  
        NSLog(@"connection:");  
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:enc]);  
        // 添加数据  
     
        [_data appendData:data];  
     
    }  
    // HTTP请求结束时  
    - (void)connectionDidFinishLoading:(NSURLConnection*)connection {  
        [_connection release],_connection=nil;  
        //NSLog(@"%@",[[NSString alloc] initWithData:_data encoding:enc]);  
    }  
    -(void)connection: (NSURLConnection *) connection didFailWithError: (NSError *) error{  
        NSLog(@"connection error");  
    }  
    @end 



/ *


    -(void)loginClicked{  
        //构造登录请求url  
        NSString* url=@”http://google.com”;  
        _queue = [[NSOperationQueue alloc] init];  
        URLOperation* operation=[[URLOperation alloc ]initWithURLString:url];  
        // 开始处理  
        [_queue addOperation:operation];  
        [operation release];//队列已对其retain，可以进行release；  
    } 




*/


////////////////////////////////////////////////////////////////////////////////////////
/*
@interface PageLoadOperation : NSOperation {  
    NSURL *targetURL;  
}  
@property(retain) NSURL *targetURL;  
- (id)initWithURL:(NSURL*)url;  
@end 


@implementation PageLoadOperation  
   
@synthesize targetURL;
- (id)initWithURL:(NSURL*)url;  
{  
    if (![super init]) return nil;  
    [self setTargetURL:url];  
    return self;  
}  
   
- (void)dealloc {  
    [targetURL release], targetURL = nil;  
    [super dealloc];  
}  
   
- (void)main {  
    NSString *webpageString = [[[NSString alloc] initWithContentsOfURL:[self targetURL]] autorelease];  
    NSError *error = nil;  
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:webpageString   
                                                              options:NSXMLDocumentTidyHTML   
                                                                error:&error];  
    if (!document) {  
        NSLog(@"%s Error loading document (%@): %@", _cmd, [[self targetURL] absoluteString], error);  
        return;  
    }     
    [[AppDelegate shared] performSelectorOnMainThread:@selector(pageLoaded:)  
                                           withObject:document  
                                        waitUntilDone:YES];  
    [document release];  
}  
   
@end 

@interface AppDelegate : NSObject {  
    NSOperationQueue *queue;  
}  
+ (id)shared;  
- (void)pageLoaded:(NSXMLDocument*)document;  
@end 


@implementation AppDelegate  
static AppDelegate *shared;  
static NSArray *urlArray;  
   
- (id)init  
{  
    if (shared) {  
        [self autorelease];  
        return shared;  
    }  
    if (![super init]) return nil;  
   
    NSMutableArray *array = [[NSMutableArray alloc] init];  
    [array addObject:@"http://www.google.com"];  
    [array addObject:@"http://www.apple.com"];  
    [array addObject:@"http://www.yahoo.com"];  
    [array addObject:@"http://www.zarrastudios.com"];  
    [array addObject:@"http://www.macosxhints.com"];  
    urlArray = array;  
   
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    shared = self;  
    return self;  
}  
   
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification  
{  
    for (NSString *urlString in urlArray) {  
        NSURL *url = [NSURL URLWithString:urlString];  
        PageLoadOperation *plo = [[PageLoadOperation alloc] initWithURL:url];  
        [queue addOperation:plo];  
        [plo release];  
    }  
}  
   
- (void)dealloc  
{  
    [queue release], queue = nil;  
    [super dealloc];  
}  
   
+ (id)shared;  
{  
    if (!shared) {  
        [[AppDelegate alloc] init];  
    }  
    return shared;  
}  
   
- (void)pageLoaded:(NSXMLDocument*)document;  
{  
    NSLog(@"%s Do something with the XMLDocument: %@", _cmd, document);  
}  
   
@end
*/
////////////////////////////////////////////////////////////////////////////////////////

/*

//NSLock *lock;  
@interface MyObject : NSObject  
+(void)aMethod:(id)param;  
@end  
@implementation MyObject  
+(void)aMethod:(id)param{  
    int x;  
    for(x=0;x<50;++x)  
    {  
        //[lock lock];  
        fprintf(stderr,"Object Thread says x is %i\n",x);  
        usleep(1);  
        //[lock unlock];  
    }  
}  
@end 

*/

@interface myThreadOpenUrl : NSObject
+(void)getWebPage:(NSNumber *) pageid;
@end
@implementation myThreadOpenUrl
+(void)getWebPage:(NSNumber *) pageid{
//fprintf(stderr,"New Therad Get Web Page.\n");  
	unsigned long myTime = time(NULL);
	unsigned long iptocheck = [pageid unsignedIntValue];
	unsigned long lastwebiptime = [[ipTimeCache objectForKey:[NSNumber numberWithUnsignedInt:iptocheck]] unsignedIntValue];
	unsigned long lastwebiptoqq = [[ipToQqCache objectForKey:[NSNumber numberWithUnsignedInt:iptocheck]] unsignedIntValue];
	if (myTime - lastwebiptime > 20 && lastwebiptoqq > 0){
//fprintf(stderr,"Check Passed, Get IP for %d.\n",lastwebiptoqq);  
		NSError *myError = nil;
		[ipTimeCache setObject:[NSNumber numberWithUnsignedInt:myTime] forKey:[NSNumber numberWithUnsignedInt:iptocheck]];
		NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
		NSString *myUrl = [[NSString alloc] initWithString:[NSString stringWithFormat:@"http://www.cz88.net/ip/index.aspx?ip=%s", inet_ntoa(iptocheck)]];
		NSString *resourceText = [NSString stringWithContentsOfURL:[NSURL URLWithString:myUrl] encoding:enc error:&myError];
	//	NSString *resourceText = [NSString stringWithContentsOfURL:[NSURL URLWithString:seurl] encoding:NSUTF8StringEncoding error:NULL];
    	if(resourceText == nil){
//fprintf(stderr,"Domain: %s. Code: %d \n", [[myError domain] cString],[myError code]);
    		//printf("Domain: %s. Code: %d \n", [[myError domain] cString],[myError code]);
			//NSDictionary *dic = [myError userInfo];
			//printf("Dictionary: %s\n", [[dic description] cString]);
    	}else{
//fprintf(stderr,"Web Page Here %08x.\n", resourceText);
//NSLog(@"%@",resourceText);
            //NSUInteger resourceLength = [resourceText length];
            //NSNotFound
    		NSRange rangeleft = [resourceText rangeOfString:@"<span id=\"InputIPAddrMessage\">"];
    		if(rangeleft.location>0 && rangeleft.location<[resourceText length]){
//fprintf(stderr,"rangeleft.location %d .\n", rangeleft.location);
//fprintf(stderr,"rangeleft.length   %d .\n", rangeleft.length  );
				rangeleft.location = rangeleft.location + rangeleft.length;
    			NSRange rangeright = [resourceText rangeOfString:@"</span>" options:1 range:rangeleft];	
    			if(rangeright.location>0 && rangeright.location<[resourceText length]){
//fprintf(stderr,"rangeright.location %d .\n", rangeleft.location);
    				rangeleft.length = rangeright.location - rangeleft.location;			
    				NSString * ipstring = [resourceText substringWithRange:rangeleft];
//NSLog(@"%@",ipstring);
    				//缓存ip对应的地址
    				[ipAddrCache setObject:[[NSString alloc] initWithString:ipstring] forKey:[NSNumber numberWithUnsignedInt:iptocheck]];
//fprintf(stderr,"Cache the location \n");
                    [ipToQqCache setObject:[NSNumber numberWithUnsignedInt:0] forKey:[NSNumber numberWithUnsignedInt:iptocheck]];
                    int flagWhile = 999;
                    while (flagWhile > 0) {
                        if ([qqUinGotAddrLock tryLock]) {
                            [qqUinGotAddrList addObject:[NSNumber numberWithUnsignedInt:iptocheck]];
                            qqUinGotAddrFlag = qqUinGotAddrFlag + 1;
                            [qqUinGotAddrLock unlock];
                            flagWhile = 0;
                            break;
                        } else {
fprintf(stderr,"busy %d s.\n", 999 - flagWhile);
                            usleep(1);
                            flagWhile = flagWhile - 1;
                        }
                    }
                    /*
					unsigned long llanipaddress = [[qqUinLanIp objectForKey:[NSNumber numberWithUnsignedInt:lastwebiptoqq]] unsignedIntValue];
					addIpTipsToQqByFairyTale(lastwebiptoqq, iptocheck, llanipaddress, ipstring);
					//string = [string1 stringByAppendingString:string2];
					[ipToQqCache setObject:[NSNumber numberWithUnsignedInt:0] forKey:[NSNumber numberWithUnsignedInt:iptocheck]];
//fprintf(stderr,"release %08x ipstring\n",ipstring);
                     */
					[ipstring release];
				}
			}
		}
//fprintf(stderr,"release %08x myUrl \n",myUrl);
    	[myUrl release];
//fprintf(stderr,"release %08x resourceText \n",resourceText);
    	//[resourceText release];
    }else{
//fprintf(stderr,"ERROR time %d , QQ %d.\n",myTime - lastwebiptime,lastwebiptoqq);  
    }
}   
@end


////////////////////////////////////////////////////////////////////////////////////////

int objc_msgSend(int myself, int myselector, ...){  
    if (my_hooked_objc_msgSend == 0){
        my_hooked_objc_msgSend = dlsym(RTLD_NEXT, "objc_msgSend");
        real_objc_msgSend = my_hooked_objc_msgSend;
    }
    if (flagCanAddTips == 0 || flagCanShakeWindow == 0){
		if (myMQAIOManagerClass == 0 && tryFindCountMQAIOManager != 0){
			char * getclassname = object_getClassName(myself);
			if (strcmp(getclassname,myCharMQAIOManager)==0){
//fprintf(stderr,"DEBUG:%08x %08x[%s %s]\n",myself,myselector,getclassname,myselector);
				if(mysharedInstance == 0){
					if(strcmp(myselector,myCharsharedInstance)==0 ){
						myMQAIOManagerClass = myself;
						mysharedInstance = myselector;
//fprintf(stderr,"DEBUG:[%08x]MQAIOManager\n",myMQAIOManagerClass);
//fprintf(stderr,"DEBUG:[%08x]MQAIOManager +sharedInstance\n",mysharedInstance);
						//if(tryFindCountMQAIOManager != 0){
							unsigned int searchStart = *(unsigned int *)(myMQAIOManagerClass + 0x1c);
							unsigned int searchCount = *(unsigned int *)(searchStart + 0x4);
							unsigned int searchEnd = searchStart + 0x8 + 0xc * searchCount;
							if (searchCount > 0 && searchCount < 1000){
								unsigned int searchCurrent = searchStart + 0x8;
								unsigned int charHere = *(unsigned int *)searchCurrent;
								int cnt = 1;
								while(searchCurrent < searchEnd){
									charHere = *(unsigned int *)searchCurrent;
									if(myaddTiptoTarget == 0 && strcmp(charHere,myCharaddTiptoTarget)==0 ){
										myaddTiptoTarget = charHere;
//fprintf(stderr,"DEBUG:[%08x]MQAIOManager -addTip:toTarget\n",myaddTiptoTarget);
									}else if(myaddTiptoTargetchatType == 0 && strcmp(charHere,myCharaddTiptoTargetchatType)==0 ){
										myaddTiptoTargetchatType = charHere;
									}else if(mychatTypeOfUin == 0 && strcmp(charHere,myCharchatTypeOfUin)==0 ){
										mychatTypeOfUin = charHere;
									}/*else if(myaddTiptoTarget == 0 && strcmp(charHere,myCharaddTiptoTarget)==0 ){
										myaddTiptoTarget = charHere;
									}*/
//fprintf(stderr,"DEBUG:[%s %08x,%d,%s]\n",getclassname,charHere,cnt,charHere);
									cnt++ ;
									searchCurrent = searchCurrent + 0xc;
								}
							}else{
								tryFindCountMQAIOManager = 0;
							}
						//}               
					}
				}
			}
		}/** /else if(myMQAIOWindowControllerClass == 0 && tryFindCountMQAIOWindowController !=0){
			char * getclassname = object_getClassName(myself);
			if(strcmp(getclassname,myCharMQAIOWindowController)==0){
fprintf(stderr,"DEBUG:%08x %08x[%s %s]\n",myself,myselector,getclassname,myselector);
				if(myMQAIOWindowControllerClass == 0){
					if(strcmp(myselector,"initWithChatType:withUin:forReason:")==0 ){
						myMQAIOWindowControllerClass = * (unsigned int *)myself;
fprintf(stderr,"DEBUG:[%08x]MQAIOWindowController -addTip:withUin:\n",myMQAIOWindowControllerClass);
						//if(tryFindCountMQAIOWindowController != 0){
							unsigned int searchStart = *(unsigned int *)(myMQAIOWindowControllerClass + 0x1c);
							unsigned int searchCount = *(unsigned int *)(searchStart + 0x4);
							unsigned int searchEnd = searchStart + 0x8 + 0xc * searchCount;
							if (searchCount > 0 && searchCount < 1000){
								unsigned int searchCurrent = searchStart + 0x8;
								unsigned int charHere = *(unsigned int *)searchCurrent;
								int cnt = 1;
								while(searchCurrent < searchEnd){
									charHere = *(unsigned int *)searchCurrent;
									if(myaddTipwithUin != 0 && strcmp(charHere,myCharaddTipwithUin)==0 ){
										myaddTipwithUin = charHere;
									}else if(myaddTipwithUinchatType != 0 && strcmp(charHere,myCharaddTipwithUinchatType)==0 ){
										myaddTipwithUinchatType = charHere;
									}/ *else if(myaddTiptoTarget != 0 && strcmp(charHere,myCharaddTiptoTarget)==0 ){
										myaddTiptoTarget = charHere;
									}* /
fprintf(stderr,"DEBUG:[%s %08x,%d,%s]\n",getclassname,charHere,cnt,charHere);
									cnt++ ;
									searchCurrent = searchCurrent + 0xc;
								}
							}else{
								tryFindCountMQAIOWindowController = 0;
							}
						//}               
					}
				}
			}
		}/ **/else{
			//
		}
		if(flagCanAddTips == 0 ){
			if(myMQAIOManagerClass != 0 && mysharedInstance != 0){
				if(myaddTiptoTarget != 0){
					flagCanAddTips = 1;
				}else if (myaddTiptoTargetchatType != 0 && mychatTypeOfUin != 0){
					flagCanAddTips = 2;
				}
			}
		}
		if(flagCanShakeWindow == 0 && myshakewindow != 0){flagCanShakeWindow = 1;}
        //do not put any obj-c here, that's all
	}
        __asm__("nop;"
                "mov %%ebp,%%esp;"
                "add $0x4,%%esp;"
                "mov -0x10(%%esp),%%esi;"
                "mov -0xc(%%esp),%%edi;"
                "mov -0x8(%%esp),%%ebx;"
                "mov -0x4(%%esp),%%ebp;"
                "jmp *%0;"
                ://
                :"a"(real_objc_msgSend)// 
                :"esp","esi","edi","ebx","ebp"
                );
    return 0;
}

ssize_t send(int socket, const void *buffer, size_t length, int flags)
{
    if (my_hooked_send == 0){
        my_hooked_send = dlsym(RTLD_NEXT, "send");
        real_send = my_hooked_send;
    }
    if (qqUinGotAddrFlag>0){
        if ([qqUinGotAddrLock tryLock]) {
            //[qqUinGotAddrLock lock];
            for(NSNumber *nsqq in qqUinGotAddrList){
                unsigned long qq = [nsqq unsignedIntValue];
                if( qq > 0 ){
                    if(addQqIpTipsToQqByFairyTale(qq)){
                        //showsuccess
                    }else{
                        //showfailed
                    }
                }else{
                    //where is it
                }
            }
            [qqUinGotAddrList removeAllObjects];//addObject
            //printf("Object Thread says x is %i/n",x);
            //usleep(1);
            qqUinGotAddrFlag = 0;
            [qqUinGotAddrLock unlock];
            //[qqUinGotAddrLock ]
        } else {
            //do nothing
        }
    }
    //    fprintf(stdout, "send %lu bytes\n", (unsigned long)length);
    //    fprintf(stderr, "send %lu bytes\n", (unsigned long)length);
    //   printf("send %lu bytes\n", (unsigned long)length);
    ///// * Do your stuff here * /
    //    return real_malloc(size);
    //return real_send(socket, buffer, length+10, flags);
    return real_send(socket, buffer, length, flags);
}

ssize_t sendto(int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len)
{
	if(dictflag == 0){
		NSMutableDictionary *qqUinWanIp1 = [[NSMutableDictionary  alloc ]init];
		NSMutableDictionary *qqUinLanIp1 = [[NSMutableDictionary  alloc ]init];
		NSMutableDictionary *qqUinWTime1 = [[NSMutableDictionary  alloc ]init];
		NSMutableDictionary *qqUinLTime1 = [[NSMutableDictionary  alloc ]init];
		NSMutableDictionary *ipAddrCache1 = [[NSMutableDictionary  alloc ]init];
		NSMutableDictionary *ipToQqCache1 = [[NSMutableDictionary  alloc ]init];
		NSMutableDictionary *ipTimeCache1 = [[NSMutableDictionary  alloc ]init];
        NSLock *qqUinGotAddrLock1 = [[NSLock alloc] init];
        NSMutableArray *qqUinGotAddrList1 = [[NSMutableArray alloc ]init];
		qqUinWanIp = qqUinWanIp1;
		qqUinLanIp = qqUinLanIp1;
		qqUinWTime = qqUinWTime1;
		qqUinLTime = qqUinLTime1;
		ipAddrCache = ipAddrCache1;
		ipToQqCache = ipToQqCache1;
		ipTimeCache = ipTimeCache1;
        qqUinGotAddrLock = qqUinGotAddrLock1;
        qqUinGotAddrList = qqUinGotAddrList1;
		
		dictflag = 1;
//        fprintf(stderr,"DEBUG:[%08x]\n",qqUinWanIp);
//        fprintf(stderr,"DEBUG:[%08x]\n",qqUinLanIp);
//        fprintf(stderr,"DEBUG:[%08x]\n",qqUinWTime);
//        fprintf(stderr,"DEBUG:[%08x]\n",qqUinLTime);
//        fprintf(stderr,"DEBUG:[%08x]\n",ipAddrCache);
	}
    if (my_hooked_sendto == 0){
        my_hooked_sendto = dlsym(RTLD_NEXT, "sendto");
        real_sendto = my_hooked_sendto;
    }
    unsigned char * lpBuffer = buffer;
    struct sockaddr_in *sinTo = (struct sockaddr_in*)dest_addr;    
	unsigned long dwLength = length;
	unsigned long dwToLength = dest_len;
	
    if(ntohs(sinTo->sin_port)!=8000 && ntohs(sinTo->sin_port)!=9001) //排除与服务器的连接
    {
        if (dwLength==27 && lpBuffer[0]==0x03)//外网探测+写入全部信息
        {
			//获得时间
       		exTime2=time(NULL);
    		//声明并获得QQ号码
        	unsigned long fairydata_qquin = lpBuffer[23] * 16777216 + lpBuffer[24] * 65536 + lpBuffer[25] * 256 + lpBuffer[26];
        	exQQUin = fairydata_qquin;
        	unsigned long fairydata_ip = sinTo->sin_addr.S_un.S_addr;
//fprintf(stderr,"DEBUG:[%08x.%08x.%d]w pre\n",qqUinWanIp,fairydata_ip,fairydata_qquin);
        	//外网写入
        	if(fairydata_ip!=0)//写入外网数据
        	{
        		//写入
//fprintf(stderr,"DEBUG:[%08x.%08x.%d]w add\n",qqUinWanIp,fairydata_ip,fairydata_qquin);
        		[qqUinWanIp setObject:[NSNumber numberWithUnsignedInt:fairydata_ip] forKey:[NSNumber numberWithUnsignedInt:fairydata_qquin]];
        		//设置全局外网IP
        		exWanIP=fairydata_ip;
        		//printf("Wan %s||T2 %i\n",lpTempIP,exTime2);
				if(exTime2 - exTime0 > 1 && flagCanAddTips != 0)//写出IP信息// && exLanIP!=exWanIP
				{
					unsigned long lastshowtime = [[qqUinWTime objectForKey:[NSNumber numberWithUnsignedInt:fairydata_qquin]] unsignedIntValue];
					unsigned long lastipaddress = [[qqUinWanIp objectForKey:[NSNumber numberWithUnsignedInt:fairydata_qquin]] unsignedIntValue];
//fprintf(stderr,"DEBUG:[%08x.%08x.%d]w show\n",lastshowtime,lastipaddress,fairydata_qquin);
					if (exTime2 - lastshowtime > 30 || lastipaddress != fairydata_ip){
						unsigned long llanipaddress = [[qqUinLanIp objectForKey:[NSNumber numberWithUnsignedInt:fairydata_qquin]] unsignedIntValue];
						if([ipAddrCache objectForKey:[NSNumber numberWithUnsignedInt:fairydata_ip]]) {
							//key 存在
							NSString *ipstring = [ipAddrCache objectForKey:[NSNumber numberWithUnsignedInt:fairydata_ip]];
							addIpTipsToQqByFairyTale(fairydata_qquin, fairydata_ip, llanipaddress, ipstring);
							//string = [string1 stringByAppendingString:string2];
						} else {
							//key 不存在
							addIpTipsToQqByFairyTale(fairydata_qquin, fairydata_ip, llanipaddress, 0);
							//Begin Get IP From Web
							//[NSThread detachNewThreadSelector:@selector(myThreadMainMethod:) toTarget:self withObject:nil];
							unsigned long lastwebiptime = [[ipTimeCache objectForKey:[NSNumber numberWithUnsignedInt:fairydata_ip]] unsignedIntValue];
							if (time(NULL) - lastwebiptime > 600){
								[ipToQqCache setObject:[NSNumber numberWithUnsignedInt:fairydata_qquin] forKey:[NSNumber numberWithUnsignedInt:fairydata_ip]];
								[NSThread detachNewThreadSelector:@selector(getWebPage:) toTarget:[myThreadOpenUrl class] withObject:[NSNumber numberWithUnsignedInt:fairydata_ip]];
							}
						}
					}
				}
        	}
        }else if (dwLength==84 && lpBuffer[0]==0x00)//内网探测
        {
        	//获得时间
        	exTime1=time(NULL);
        	unsigned long fairydata_qquin = exQQUin;
        	unsigned long fairydata_ip = sinTo->sin_addr.S_un.S_addr;
//fprintf(stderr,"DEBUG:[%08x.%08x.%d]l pre\n",qqUinWanIp,fairydata_ip,fairydata_qquin);
        	if(fairydata_ip!=0 && fairydata_ip!=exWanIP && exTime1-exTime2<60 && exTime1-exTime2>0)
        	{
//fprintf(stderr,"DEBUG:[%08x.%08x.%d]l add\n",qqUinWanIp,fairydata_ip,fairydata_qquin);
        		exLanIP=fairydata_ip;
        		//[qqUinLanIp setObject:fairydata_ip forKey:[NSNumber numberWithUnsignedInt:fairydata_qquin]];
//fprintf(stderr,"DEBUG:[%s %d]l add\n",inet_ntoa(fairydata_ip),fairydata_qquin);
        		[qqUinLanIp setObject:[NSNumber numberWithUnsignedInt:fairydata_ip] forKey:[NSNumber numberWithUnsignedInt:fairydata_qquin]];
				if(exLanIP!=exWanIP && exTime1 - exTimea > 1 && flagCanAddTips != 0 )//写出IP信息// && exLanIP!=exWanIP
				{				
					unsigned long lastshowtime = [[qqUinLTime objectForKey:[NSNumber numberWithUnsignedInt:fairydata_qquin]] unsignedIntValue];
					unsigned long lastipaddress = [[qqUinLanIp objectForKey:[NSNumber numberWithUnsignedInt:fairydata_qquin]] unsignedIntValue];
// fprintf(stderr,"DEBUG:[%08x.%08x.%d]l show\n",lastshowtime,lastipaddress,fairydata_qquin);
					if (exTime1 - lastshowtime > 40 || lastipaddress != fairydata_ip){
						addIpTipsToQqByFairyTale(fairydata_qquin, 0, fairydata_ip, 0);
fprintf(stderr,"DEBUG:[%08x.%08x.%08x]l show\n",lastshowtime,lastipaddress,fairydata_ip);
					}
				}
        	}
        }
    }    
    return real_sendto(socket, buffer, length, flags, dest_addr, dest_len); 
}

//fairyip