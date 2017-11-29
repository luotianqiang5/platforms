//
//  RewardedAdsManager.m
//  NewAdsManager
//
//  Created by zengwenbin on 15/7/9.
//  Copyright (c) 2015年 zengwenbin. All rights reserved.
//

#import "RewardedAdsManager.h"
#import "FullscreenAdBase.h"
#import "AdDeviceHelper.h"
#import "InterstitialAdsManager.h"
#import "FullscreenAdMob.h"
#import "CrosspromoAdsManager.h"
#import "AdIdHelper.h"
#import "AdDef.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define AD_TYPE @"rewarded"

@interface RewardedAdsManager()<FullscreenAdDelegate,GADRewardBasedVideoAdDelegate>
@property (nonatomic, assign) BOOL  isPreloading;
@property (nonatomic, assign) BOOL  isConfig;
@end

@implementation RewardedAdsManager

+ (instancetype)getInstance
{
    static RewardedAdsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [RewardedAdsManager new];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _isDebugModel = NO;
        
        
        //
        //#if RewardedType == AdsTypeMopub
        //        self.fullscreenAd=[[FullscreenAdMopubRewarded new] autorelease];
        //#elif RewardedType == AdsTypeFyber || RewardedType == AdsTypeFyberNew
        //        self.fullscreenAd=[[FullScreenAdFyberRewarded new] autorelease];
        //#elif RewardedType == AdsTypeAdColony
        //        self.fullscreenAd = [[FullscreenAdAdColonyRewarded new] autorelease];
        //#else
        //        self.fullscreenAd=nil;
        //        return nil;
        //#endif
        
        //        self.fullscreenAd.delegate = self;
        //        self.fullscreenAd.adId = adId;
        //        self.fullscreenAd.isRewarded = YES;
        //        self.fullscreenAd.isDebugModel = NO;
        
        self.isPreloading = NO;
        self.isPreloaded = NO;
        self.autoShow = NO;
        self.isConfig = NO;
        self.isSkip = YES;
        [GADRewardBasedVideoAd sharedInstance].delegate = self;
        //[self configure];
    }
    
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    
    [super dealloc];
}

- (void)setIsDebugModel:(BOOL)isDebugModel
{
    _isDebugModel = isDebugModel;
}

- (BOOL)configure
{
    NSString *adId = [[AdIdHelper sharedAdIdHelper].rewardedId copy];
    if(adId.length <= 0){
        return NO;
    }
    
    NSArray *adIdArr = [adId componentsSeparatedByString:@","];
    if(adIdArr.count == 2){
        //static dispatch_once_t onceToken;
        //dispatch_once(&onceToken, ^{
        //if(NO == self.isPreloading)
        
        if([self isPreloaded])
        {
            [self onLoaded];
            if(_autoShow)
                [self show];
        }
        else
        {
      
            if(_isConfig == NO){
                _isConfig = YES;
                self.zoneID = [adIdArr[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
//            GADRequest *request = [GADRequest request];
//            [[GADRewardBasedVideoAd sharedInstance] loadRequest:request withAdUnitID:adIdArr[0]];
        }
        //});
        
        return YES;
    }
    
    return NO;
}

- (void)preload
{
    if(NO == [self configure])
    {
        [self onFailed: nil];
    }else {
        if((NO == self.isPreloading)&&(![[GADRewardBasedVideoAd sharedInstance] isReady])) {
              self.isPreloading = YES;
                 [GADRewardBasedVideoAd sharedInstance].delegate = self;
             GADRequest *request = [GADRequest request];
            [[GADRewardBasedVideoAd sharedInstance] loadRequest:request withAdUnitID:self.zoneID];
        }
    }
}

- (BOOL)show
{
    if(self.isShowing){
        return YES;
    }
    
    if([InterstitialAdsManager getInstance].isShowing){
        return NO;
    }
    
    if([CrosspromoAdsManager getInstance].isShowing){
        return NO;
    }
    if(NO == _isPreloaded)
        return  NO;
    //    if(NO == [AdColony isVirtualCurrencyRewardAvailableForZone:self.zoneID])
    //    {
    //        return NO;
    //    }
    if(![[GADRewardBasedVideoAd sharedInstance] isReady])
        return NO;
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(vc.presentingViewController || vc.presentedViewController){
        return NO;
    }
    self.isSkip = YES;
    [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:vc];
    
    return YES;
}

- (void)setAutoShow:(BOOL)autoShow
{
    _autoShow = autoShow;
}

//- (BOOL)isPreloaded
//{
//    return [AdColony zoneStatusForZone:self.zoneID] == ADCOLONY_ZONE_STATUS_ACTIVE;
//}

- (BOOL)isShowing
{
    return _isShowing;
}

#pragma mark - admobRewardDeleget

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    self.isPreloading = NO;
    _isPreloaded = YES;
    
    [self onLoaded];
    if(_autoShow)
        [self show];
    
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
    [self onExpanded];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
    self.isPreloading = NO;
    [self onRewarded:@"Reward" rewardedNum:0 isSkipped:self.isSkip];
    [self onCollapsed];
    [self preload];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
    
    self.isPreloading = NO;
    self.isSkip = NO;
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load.");
    self.isPreloading = NO;
    _isPreloaded = false;
    [self onFailed:nil];
}




#pragma mark - 全屏回调

- (void)onLoaded
{
    self.isPreloading = NO;
    
    if(self.isShowing)
        return;
    
    if([self.delegate respondsToSelector:@selector(onRewardedLoaded)]){
        [self.delegate onRewardedLoaded];
    }
    
    id temp = [UIApplication sharedApplication].delegate;
    if(temp && [temp respondsToSelector:@selector(onAdsLoaded:)])
    {
        NSDictionary* dict = @{@"type":AD_TYPE};
        [temp onAdsLoaded:dict];
    }
}

- (void)onFailed:(NSError *)error
{
    self.isPreloading = NO;
    
    if(self.isShowing || self.isPreloaded)
        return;
    
    if([self.delegate respondsToSelector:@selector(onRewardedFailed:)]){
        [self.delegate onRewardedFailed:error];
    }
    
    id temp = [UIApplication sharedApplication].delegate;
    if(temp && [temp respondsToSelector:@selector(onAdsFailed:)])
    {
        NSDictionary* dict = @{@"type":AD_TYPE};
        [temp onAdsFailed:dict];
    }
}

- (void)onExpanded
{
    _isShowing = YES;
    
    if([self.delegate respondsToSelector:@selector(onRewardedExpanded)]){
        [self.delegate onRewardedExpanded];
    }
    
    id temp = [UIApplication sharedApplication].delegate;
    if(temp && [temp respondsToSelector:@selector(onAdsExpanded:)])
    {
        NSDictionary* dict = @{@"type":AD_TYPE};
        [temp onAdsExpanded:dict];
    }
}

- (void)onCollapsed
{
    _isShowing = NO;
    
    if([self.delegate respondsToSelector:@selector(onRewardedCollapsed)]){
        [self.delegate onRewardedCollapsed];
    }
    
    id temp = [UIApplication sharedApplication].delegate;
    if(temp && [temp respondsToSelector:@selector(onAdsCollapsed:)])
    {
        NSDictionary* dict = @{@"type":AD_TYPE};
        [temp onAdsCollapsed:dict];
    }
}

- (void)onRewarded:(NSString *)rewardedItem rewardedNum:(NSInteger)rewardedNum isSkipped:(BOOL)isSkipped
{
    _isShowing = NO;
    
    if([self.delegate respondsToSelector:@selector(onRewarded:rewardedNum:isSkipped:)]){
        [self.delegate onRewarded:rewardedItem rewardedNum:rewardedNum isSkipped:isSkipped];
    }
    
    id temp = [UIApplication sharedApplication].delegate;
    if(temp && [temp respondsToSelector:@selector(onAdsRewarded:)])
    {
        NSDictionary* dict = @{@"type":AD_TYPE};
        [temp onAdsRewarded:dict];
    }
}

@end
