//
//  AddFoodViewController.m
//  Health App
//
//  Created by Brandon Shega on 2/14/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import "AddFoodViewController.h"
#import "Food.h"
#import "Food+Create.h"

@interface AddFoodViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *calorieField;

@end

@implementation AddFoodViewController

@synthesize nameField, calorieField, managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//function to save a new food to the list
- (IBAction)saveAction:(id)sender
{
    NSNumberFormatter *nf = [NSNumberFormatter new];
    nf.numberStyle = NSNumberFormatterDecimalStyle;
    
    //save book here
    [Food foodWithName:[nameField text] calories:[nf numberFromString:[calorieField text]] inManagedObjectContext:managedObjectContext];
    
    [managedObjectContext save:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//user cancelled adding food
- (IBAction)cancelAction:(id)sender
{
    //dismiss modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
