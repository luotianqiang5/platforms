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
    _moreGameController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    //  [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppConfig.plist" ofType:nil]];
    NSString* servers=[dic valueForKey:@"ServerBaseUrl"];
    NSString *url= [NSString stringWithFormat:@"%@/moregames/?platform=31&bundleId=%@",servers,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    //    NSString *url= [NSString stringWithFormat:@"%@/moregames/?platform=31&bundleId=%@&notshowclose=1",servers,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    //    return ;
    UIWindow *vc = [UIApplication sharedApplication].keyWindow;
    CGRect _rect = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
    UIWebView *_webView= [[UIWebView alloc]initWithFrame:_rect];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 3.5f]];
    _webView.delegate = self;
    [_moreGameController.view addSubview:_webView];
    //[vc bringSubviewToFront:webView];
    
    _active = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _active.center = _webView.center;;
    [_active setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _active.color = [UIColor grayColor];
    [_moreGameController.view addSubview:_active];
    [_active release];
    [_webView release];
    //    PrivacyPage *page = [PrivacyPage privacyPage];
    //
    //    RootViewController *vc=[AppController sharedAppController].viewController;
    //    [page showInView:vc.view];
    //    [page release];
    [_active startAnimating];
    [vc.rootViewController presentViewController:_moreGameController animated:YES completion:nil];
}


//网页是否要加载
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if( navigationType == UIWebViewNavigationTypeLinkClicked && _moreGameController != nil) {
        //第二中方法  应用内跳转
        //1:导入StoreKit.framework,控制器里面添加框架#import <StoreKit/StoreKit.h>
        //2:实现代理SKStoreProductViewControllerDelegate
        NSURL* url = [request URL];
        NSString* urlStr =  url.absoluteString;
        if(urlStr == nil || urlStr.length == 0 || [urlStr rangeOfString:@"#"].location != NSNotFound)
            return  YES;
        NSString *regexString = @"/id[0-9]+";
        NSRange range = [urlStr rangeOfString:regexString options:NSRegularExpressionSearch];
        if(range.location == NSNotFound)
            return YES;
        NSString* idString = [urlStr substringWithRange:range];
        NSString* numRegex = @"[0-9]+";
        NSRange numRnage = [idString rangeOfString:numRegex options:NSRegularExpressionSearch];
        if(numRnage.location == NSNotFound)
            return YES;
        SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
        storeProductViewContorller.delegate = self;
        [_moreGameController presentViewController:storeProductViewContorller animated:YES completion:nil];
        
        //加载一个新的视图展示
        [storeProductViewContorller loadProductWithParameters:
  @{SKStoreProductParameterITunesItemIdentifier : [idString substringWithRange:numRnage]} completionBlock:nil];
        return     NO;
    }
    return YES;
}
//网页开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    
}
//网页加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_active stopAnimating];
    _active = nil;
    // _webView.delegate = nil;
    // 设置javaScriptContext上下文
    JSContext *jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    jsContext[@"clickedCloseButton"] = ^(NSString *event){
        if(_moreGameController != nil)
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_moreGameController != nil){
                    [_moreGameController dismissViewControllerAnimated:YES completion:nil];
                }
                _moreGameController = nil;
            });
        
    };
}
//网页加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [_active stopAnimating];
    _active = nil;
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"The Internet connection appears to be offline." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(_moreGameController != nil)
        [_moreGameController dismissViewControllerAnimated:YES completion:nil];
    _moreGameController = nil;
}
//取消按钮监听
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
@end