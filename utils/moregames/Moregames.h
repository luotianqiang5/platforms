//
//  moregames.h
//  frozenfood
//
//  Created by luotianqiang on 17/6/23.
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <StoreKit/StoreKit.h>

@interface Moregames : NSObject<UIWebViewDelegate,JSExport,UIAlertViewDelegate,SKStoreProductViewControllerDelegate>
{

}
@property(nonatomic, strong) UIViewController *moreGameController;
@property(nonatomic, strong) UIActivityIndicatorView *active;
+(Moregames*)sharedManager;

-(void)showMoreGamePage;
@end