//
//  ProfileViewController.h
//  Health App
//
//  Created by Brandon Shega on 2/14/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

@interface ProfileViewController : UIViewController

@property (nonatomic, strong) HKHealthStore *healthStore;

- (void)getUsersAge;
- (void)getUsersHeight;
- (void)getUsersWeight;

@end
