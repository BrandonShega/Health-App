//
//  Food+Create.h
//  Health App
//
//  Created by Brandon Shega on 2/14/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import "Food.h"

@interface Food (Create)

+ (Food *)foodWithName:(NSString *)name calories:(NSNumber *)calories inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Food *)foodWithName:(NSString *)name calories:(NSNumber *)calores;

@end
