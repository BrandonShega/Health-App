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

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getUsersAge];
    [self getUsersHeight];
    [self getUsersWeight];
    
}

- (IBAction)calculateBMI:(id)sender
{
    
    double weight = [[self.weightField text] doubleValue];
    double height = [[self.heightField text] doubleValue];
    
    double bmi = (weight * 703) / (height * height);
    
    self.bmiField.text = [NSString stringWithFormat:@"%.2f", bmi];
    
}

- (IBAction)saveProfile:(id)sender
{
    NSMutableArray *objectsToSave = [NSMutableArray array];
    
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
    
    NSDate *today = [NSDate date];
    
    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:today endDate:today];
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:today endDate:today];
    HKQuantitySample *bmiSample = [HKQuantitySample quantitySampleWithType:bmiType quantity:bmiQuantity startDate:today endDate:today];
    
    [objectsToSave addObject:heightSample];
    [objectsToSave addObject:weightSample];
    [objectsToSave addObject:bmiSample];
    
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

- (void)getUsersAge
{
    
    NSError *error;
    
    NSDate *birthday = [self.healthStore dateOfBirthWithError:&error];
    
    NSDate *today = [NSDate date];
    
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:birthday toDate:today options:NSCalendarWrapComponents];
    
    NSInteger age = [ageComponents year];
    
    self.ageField.text = [NSString stringWithFormat:@"%li", (long)age];
    
}

- (void)getUsersHeight
{
    
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:1 sortDescriptors:@[descriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        HKQuantitySample *quantitySample = [results firstObject];
        HKQuantity *quantity = [quantitySample quantity];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            double height = 0.0;
            
            if (quantity != nil) {
                
                height = [quantity doubleValueForUnit:[HKUnit inchUnit]];
                
                self.heightField.text = [NSString stringWithFormat:@"%g", height];
                
            }
            
        });
        
    }];
    
    [self.healthStore executeQuery:query];
    
}

- (void)getUsersWeight
{
    
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:1 sortDescriptors:@[descriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        HKQuantitySample *quantitySample = [results firstObject];
        HKQuantity *quantity = [quantitySample quantity];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            double weight = 0.0;
            
            if (quantity != nil) {
                
                weight = [quantity doubleValueForUnit:[HKUnit poundUnit]];
                
                self.weightField.text = [NSString stringWithFormat:@"%g", weight];
                
            }
            
        });
        
    }];
    
    [self.healthStore executeQuery:query];
    
}
@end
