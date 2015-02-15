//
//  ProfileViewController.m
//  Health App
//
//  Created by Brandon Shega on 2/14/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@property (nonatomic, weak) IBOutlet UITextField *ageField;
@property (nonatomic, weak) IBOutlet UITextField *heightField;
@property (nonatomic, weak) IBOutlet UITextField *weightField;
@property (nonatomic, weak) IBOutlet UITextField *bmiField;

@property (nonatomic, strong) NSString *usersGender;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //get user's information
    [self getUsersAge];
    [self getUsersHeight];
    [self getUsersWeight];
    [self getUsersGender];
    
}

//function to calculate user's BMI
- (IBAction)calculateBMI:(id)sender
{
    
    double weight = [[self.weightField text] doubleValue];
    double height = [[self.heightField text] doubleValue];
    
    double bmi = (weight * 703) / (height * height);
    
    self.bmiField.text = [NSString stringWithFormat:@"%.2f", bmi];
    
}

//function to save user's profile
- (IBAction)saveProfile:(id)sender
{
    NSMutableArray *objectsToSave = [NSMutableArray array];
    
    //grab values from text fields
    double weight = [[self.weightField text] doubleValue];
    double height = [[self.heightField text] doubleValue];
    double bmi = [[self.bmiField text] doubleValue];
    
    //height sample
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:[HKUnit inchUnit] doubleValue:height];
    
    //weight sample
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:[HKUnit poundUnit] doubleValue:weight];
    
    //bmi sample
    HKQuantityType *bmiType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    HKQuantity *bmiQuantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:bmi];
    
    //sample date
    NSDate *today = [NSDate date];
    
    //create samples
    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:today endDate:today];
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:today endDate:today];
    HKQuantitySample *bmiSample = [HKQuantitySample quantitySampleWithType:bmiType quantity:bmiQuantity startDate:today endDate:today];
    
    //add to save array
    [objectsToSave addObject:heightSample];
    [objectsToSave addObject:weightSample];
    [objectsToSave addObject:bmiSample];
    
    //save objects to health kit
    [self.healthStore saveObjects:objectsToSave withCompletion:^(BOOL success, NSError *error) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                
                NSLog(@"Successfully saved objects to health kit");
                
            } else {
                
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
            }
           
        });
        
    }];
    
}

- (void)getUsersGender
{
    
    NSError *error;
    
    HKBiologicalSexObject *gender = [self.healthStore biologicalSexWithError:&error];
    
    if (gender != nil) {
        
        switch (gender.biologicalSex) {
            case HKBiologicalSexNotSet:
                
                self.usersGender = nil;
                
                break;
                
            case HKBiologicalSexFemale:
                
                self.usersGender = @"female";
                
                break;
                
            case HKBiologicalSexMale:
                
                self.usersGender = @"male";
                
                break;
                
            default:
                break;
        }
        
    }
    
}

//function to get user's age
- (void)getUsersAge
{
    
    NSError *error;
    
    NSInteger age = 0;
    
    //get birthday from health kit
    NSDate *birthday = [self.healthStore dateOfBirthWithError:&error];
    
    if (birthday != nil) {
    
        NSDate *today = [NSDate date];
        
        //break up date into components
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:birthday toDate:today options:NSCalendarWrapComponents];
        
        age = [ageComponents year];
            
    }
    
    //set text field
    self.ageField.text = [NSString stringWithFormat:@"%li", (long)age];
    
}

//function to get user's height
- (void)getUsersHeight
{
    
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    //query to get height sample points
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:1 sortDescriptors:@[descriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        HKQuantitySample *quantitySample = [results firstObject];
        HKQuantity *quantity = [quantitySample quantity];
        
        //jump back to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
           
            double height = 0.0;
            
            //if something was returned
            if (quantity != nil) {
                
                height = [quantity doubleValueForUnit:[HKUnit inchUnit]];
                
                //set text field
                self.heightField.text = [NSString stringWithFormat:@"%g", height];
                
            }
            
        });
        
    }];
    
    //execute query
    [self.healthStore executeQuery:query];
    
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
                self.weightField.text = [NSString stringWithFormat:@"%g", weight];
                
            }
            
        });
        
    }];
    
    //execute query
    [self.healthStore executeQuery:query];
    
}
@end
