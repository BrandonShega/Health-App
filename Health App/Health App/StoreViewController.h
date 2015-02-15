//
//  StoreViewController.h
//  Health App
//
//  Created by Brandon Shega on 2/15/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface StoreViewController : UIViewController <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@end
