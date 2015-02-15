//
//  CalorieCounterViewController.h
//  Health App
//
//  Created by Brandon Shega on 2/15/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@interface CalorieCounterViewController : UIViewController

@property (nonatomic, strong) HKHealthStore *healthStore;

- (void)getUsersWeight;

@end
