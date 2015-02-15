//
//  FoodLogTableViewController.m
//  Health App
//
//  Created by Brandon Shega on 2/14/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import "FoodLogTableViewController.h"
#import "FoodTableViewController.h"
#import "Food.h"
#import "Food+Create.h"
#import "FoodObject.h"

@interface FoodLogTableViewController ()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) NSMutableArray *foods;

@end

@implementation FoodLogTableViewController

@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([HKHealthStore isHealthDataAvailable]) {
        
        NSSet *dataTypesToWrite = [self dataTypesToWrite];
        NSSet *dataTypesToRead = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:dataTypesToWrite readTypes:dataTypesToRead completion:^(BOOL success, NSError *error) {
            
            if (!success) {
                
                NSLog(@"Health Kit was not given the correct permissions");
                
                return;
                
            }
            
        }];
        
    }
    
    self.foods = [NSMutableArray array];
    
    [self updateLog];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLog
{
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [calendar startOfDayForDate:[NSDate date]];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        if (!results) {
            
            NSLog(@"No results were returned from query");
            
        } else if (error) {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.foods removeAllObjects];
            
            for (NSInteger i = 0; i < [results count]; i++) {
                
                FoodObject *food = [FoodObject new];
                
                HKQuantitySample *sample = (HKQuantitySample *)results[i];
                double foodCalories = [[sample quantity] doubleValueForUnit:[HKUnit kilocalorieUnit]];
                food.name = [[sample metadata] objectForKey:HKMetadataKeyFoodType];
                food.calories = @(foodCalories);
                
                [self.foods addObject:food];
                
            }
            
            [self.tableView reloadData];
            
        });
        
    }];
    
    [self.healthStore executeQuery:query];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.foods count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Food Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    Food *food = [self.foods objectAtIndex:indexPath.row];
    
    cell.textLabel.text = food.name;
    cell.detailTextLabel.text = [food.calories stringValue];
    
    return cell;
}

- (NSSet *)dataTypesToWrite
{
    
    HKQuantityType *energyConsumed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *energyBurned = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *height = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weight = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *bmi = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    
    return [NSSet setWithObjects:energyConsumed, energyBurned, weight, height, bmi, nil];
    
}

- (NSSet *)dataTypesToRead
{
    
    HKQuantityType *energyConsumed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *energyBurned = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *height = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weight = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthday = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSex = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    return [NSSet setWithObjects:energyConsumed, energyBurned, height, weight, birthday, biologicalSex, nil];
    
}

- (IBAction)performUnwindSegue:(UIStoryboardSegue *)segue
{
    
    FoodTableViewController *ftvc = [segue sourceViewController];
    
    Food *selectedFood = ftvc.selectedFood;
    
    [self addFood:selectedFood];
}

- (void)addFood:(Food *)food
{
    
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:[food.calories doubleValue]];
    
    NSDate *today = [NSDate date];
    
    NSDictionary *metaData = @{HKMetadataKeyFoodType:food.name};
    
    HKQuantitySample *foodSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:today endDate:today metadata:metaData];
    
    [self.healthStore saveObject:foodSample withCompletion:^(BOOL success, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if (success) {
                
                [self.foods insertObject:food atIndex:0];
                
                NSIndexPath *insertedRow = [NSIndexPath indexPathForRow:0 inSection:0];
                
                [self.tableView insertRowsAtIndexPaths:@[insertedRow] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                NSLog(@"Saved object successfully into health store.");
                
            } else {
                
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
            }
            
        }); 
        
    }];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"ChooseFood"]) {
        
        FoodTableViewController *ftvc = [segue destinationViewController];
        ftvc.managedObjectContext = self.managedObjectContext;
        
    }
    
}


@end
