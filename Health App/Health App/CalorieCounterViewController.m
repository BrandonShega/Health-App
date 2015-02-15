//
//  CalorieCounterViewController.m
//  Health App
//
//  Created by Brandon Shega on 2/15/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import "CalorieCounterViewController.h"
#import "ProfileViewController.h"

@interface CalorieCounterViewController ()

@property (nonatomic) double usersWeight;

@property (nonatomic, weak) IBOutlet UITextField *speedField;
@property (nonatomic, weak) IBOutlet UITextField *weightField;
@property (nonatomic, weak) IBOutlet UITextField *inclineField;
@property (nonatomic, weak) IBOutlet UITextField *timeField;

@property (nonatomic, weak) IBOutlet UILabel *calorieLabel;

@end

@implementation CalorieCounterViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self getUsersWeight];
    
}

//function to get user's weight
- (void)getUsersWeight
{
    
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    //query to get weight sample points
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:1 sortDescriptors:@[descriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        HKQuantitySample *quantitySample = [results firstObject];
        HKQuantity *quantity = [quantitySample quantity];
        
        //jump back to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            double weight = 0.0;
            
            //if something was returned
            if (quantity != nil) {
                
                weight = [quantity doubleValueForUnit:[HKUnit poundUnit]];
                
                //set text field
                self.weightField.text = [NSString stringWithFormat:@"%.2f", weight];
                
            }
            
        });
        
    }];
    
    //execute query
    [self.healthStore executeQuery:query];
    
}

- (IBAction)calculateCalories:(id)sender
{
    double speedMPH = [[self.speedField text] doubleValue];
    
    //convert speed to meters per minute
    double speed = speedMPH * 26.8;
    
    //convert weight to kilograms
    double weight = [[self.weightField text] doubleValue] / 2.2;
    
    //convert incline to percent
    double incline = [[self.inclineField text] doubleValue] / 100;
    
    double oxygen = 0.0;
    double time = [[self.timeField text] doubleValue];
    
    //calculate amount of oxygen used
    if (speedMPH <= 3.7) {
        
        //user was walking
        oxygen = (0.1 * speed) + (1.8 * speed * incline) + 3.5;
        
    } else {
        
        //user was running
        oxygen = (0.2 * speed) + (0.9 * speed * incline) + 3.5;
    }
    
    //calculate calories burned per minute
    double cpm = (oxygen * weight) / 200;
    
    //calculate total calories burned
    double calories = cpm * time;
    
    self.calorieLabel.text = [NSString stringWithFormat:@"%.2f", calories];
    
}

- (IBAction)saveCalories:(id)sender
{
    
    //get calorie value
    double calories = [self.calorieLabel.text doubleValue];
    
    //create sample
    HKQuantityType *calorieType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantity *calorieQuantity = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:calories];
    
    //sample date
    NSDate *today = [NSDate date];
    
    //create sample
    HKQuantitySample *calorieSample = [HKQuantitySample quantitySampleWithType:calorieType quantity:calorieQuantity startDate:today endDate:today];

    //save objects to health kit
    [self.healthStore saveObject:calorieSample withCompletion:^(BOOL success, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                
                NSLog(@"Successfully saved objects to health kit");
                
            } else {
                
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
            }
            
        });
        
    }];
    
}

@end
