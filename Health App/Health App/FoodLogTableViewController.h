//
//  FoodLogTableViewController.h
//  Health App
//
//  Created by Brandon Shega on 2/14/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Food.h"
#import <HealthKit/HealthKit.h>

@interface FoodLogTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)addFood:(Food *)food;

@end
