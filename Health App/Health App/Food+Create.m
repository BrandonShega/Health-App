//
//  Food+Create.m
//  Health App
//
//  Created by Brandon Shega on 2/14/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import "Food+Create.h"

@implementation Food (Create)

//category function to create new instance and insert into Core Data
+ (Food *)foodWithName:(NSString *)name calories:(NSNumber *)calories inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    Food *newFood = nil;
    
    //request to see if unique object already exists
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Food"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (![matches count]) {
        
        //no objects were found so create a new one
        newFood = [NSEntityDescription insertNewObjectForEntityForName:@"Food" inManagedObjectContext:context];
        
        newFood.name = name;
        newFood.calories = calories;
        
    } else {
        
        //object was found, set it to the food
        newFood = [matches firstObject];
        
    }
    
    return newFood;
    
}

//category function to create new instance without inserting into database
+ (Food *)foodWithName:(NSString *)name calories:(NSNumber *)calories
{
    
    Food *newFood = nil;
    
    newFood.name = name;
    newFood.calories = calories;
    
    return newFood;
    
}

@end
