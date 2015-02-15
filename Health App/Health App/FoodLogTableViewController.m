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
    
    //check if health kit is available on this device
    if ([HKHealthStore isHealthDataAvailable]) {
        
        //set data types we want to read and write
        NSSet *dataTypesToWrite = [self dataTypesToWrite];
        NSSet *dataTypesToRead = [self dataTypesToRead];
        
        //request authorization
        [self.healthStore requestAuthorizationToShareTypes:dataTypesToWrite readTypes:dataTypesToRead completion:^(BOOL success, NSError *error) {
            
            if (!success) {
                
                //user did not authorize
                NSLog(@"Health Kit was not given the correct permissions");
                
                return;
                
            }
            
        }];
        
    }
    
    self.foods = [NSMutableArray array];
    
    //pull most recent data from health kit
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
    
    //query to find sample types for calories consumed
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        if (!results) {
            
            NSLog(@"No results were returned from query");
            
        } else if (error) {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
        
        //jump back to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //clear list out of existing data
            [self.foods removeAllObjects];
            
            //loop through each result
            for (NSInteger i = 0; i < [results count]; i++) {
                
                //create new FoodObject
                FoodObject *food = [FoodObject new];
                
                //assign properties
                HKQuantitySample *sample = (HKQuantitySample *)results[i];
                double foodCalories = [[sample quantity] doubleValueForUnit:[HKUnit kilocalorieUnit]];
                food.name = [[sample metadata] objectForKey:HKMetadataKeyFoodType];
                food.calories = @(foodCalories);
                
                //add to array
                [self.foods addObject:food];
                
            }
            
            //reload tableView data
            [self.tableView reloadData];
            
        });
        
    }];
    
    //execute query
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
    //data types that we would like to write to
    HKQuantityType *energyConsumed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *energyBurned = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *height = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weight = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *bmi = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    
    return [NSSet setWithObjects:energyConsumed, energyBurned, weight, height, bmi, nil];
    
}

- (NSSet *)dataTypesToRead
{
    
    //data types that we would like to read from
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
    //unwind segue that runs when we select a food to add to our log
    FoodTableViewController *ftvc = [segue sourceViewController];
    
    Food *selectedFood = ftvc.selectedFood;
    
    //add food to log
    [self addFood:selectedFood];
}

//function to add food to log
- (void)addFood:(Food *)food
{
    
    //create quantity type for calories consumed
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:[food.calories doubleValue]];
    
    NSDate *today = [NSDate date];
    
    NSDictionary *metaData = @{HKMetadataKeyFoodType:food.name};
    
    //create new food sample
    HKQuantitySample *foodSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:today endDate:today metadata:metaData];
    
    //save object to health kit
    [self.healthStore saveObject:foodSample withCompletion:^(BOOL success, NSError *error) {
        
        //jump back to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
        
            if (success) {
                
                //insert new food into array for tableView
                [self.foods insertObject:food atIndex:0];
                
                NSIndexPath *insertedRow = [NSIndexPath indexPathForRow:0 inSection:0];
                
                //animate row insertion
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
        
        //pass Core Data context to modal next view controller
        FoodTableViewController *ftvc = [segue destinationViewController];
        ftvc.managedObjectContext = self.managedObjectContext;
        
    }
    
}


@end
