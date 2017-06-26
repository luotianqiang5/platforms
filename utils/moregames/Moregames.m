//
//  moregames.m
//  frozenfood
//
//  Created by luotianqiang on 17/6/23.
//
//

#import <Foundation/Foundation.h>
#import "Moregames.h"
static Moregames *s_instance=nil;

@implementation Moregames

+(Moregames*)sharedManager
{
    if(s_instance==nil){
        s_instance=[[Moregames alloc] init];
    }
    return s_instance;
}



-(void)dealloc
{
    s_instance = 0;
    [super dealloc];
}


-(void)showMoreGamePage
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
      UIWindow *vc = [UIApplication sharedApplication].keyWindow;
    UIWebView* webView = [[UIWebView alloc]initWithFrame:vc.rootViewController.view.frame];
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppConfig.plist" ofType:nil]];
    NSString* servers=[dic valueForKey:@"ServerBaseUrl"];
    NSString *url= [NSString stringWithFormat:@"%@/moregames/?platform=31&bundleId=%@",servers,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 5]];
    webView.delegate = self;

    [vc addSubview:webView];
    //[vc bringSubviewToFront:webView];

    _active = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _active.center = vc.center;
    [_active setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _active.color = [UIColor grayColor];
    [vc addSubview:_active];
    [_active release];
        [webView release];
    //    PrivacyPage *page = [PrivacyPage privacyPage];
    //
    //    RootViewController *vc=[AppController sharedAppController].viewController;
    //    [page showInView:vc.view];
    //    [page release];
     [_active startAnimating];
}


//网页是否要加载
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}
//网页开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView {
  
    
}
//网页加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView {
     [_active stopAnimating];
    // 设置javaScriptContext上下文
    JSContext *jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    jsContext[@"clickedCloseButton"] = ^(NSString *event){
        if(webView != nil){
            [webView removeFromSuperview];
        }
    };
}
//网页加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    if(webView != nil){
        [webView removeFromSuperview];
    }
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error occured" message:@"please check network" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}



@end