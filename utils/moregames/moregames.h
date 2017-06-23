//
//  moregames.h
//  frozenfood
//
//  Created by luotianqiang on 17/6/23.
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>



@interface Moregames : NSObject<UIWebViewDelegate,JSExport,UIAlertViewDelegate>
{

}

+(Moregames*)sharedManager;

-(void)showMoreGamePage;
@end