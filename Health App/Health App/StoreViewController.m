//
//  StoreViewController.m
//  Health App
//
//  Created by Brandon Shega on 2/15/15.
//  Copyright (c) 2015 Brandon Shega. All rights reserved.
//

#import "StoreViewController.h"

@interface StoreViewController ()

@property (nonatomic, weak) NSString *productID;
@property (nonatomic, strong) SKProduct *product;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation StoreViewController

- (IBAction)purchase:(id)sender
{
    //create payment object
    SKPayment *payment = [SKPayment paymentWithProduct:self.product];
    
    //add to queue
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

-(IBAction)restore:(id)sender
{
    //get purchased transactions
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.indicator.hidden = YES;
    
    self.productID = @"productID";
    
    if ([SKPaymentQueue canMakePayments]) {
        
        //request for product(s) based on id(s)
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.productID]];
        request.delegate = self;
        
        [request start];
        
    }
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    //check if any products were returned
    if ([response.products count] > 0) {
        
        self.product = [response.products firstObject];
        
    } else {
        
        NSLog(@"No products were returned");
        
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    //loop over transactions
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                
                [self.indicator startAnimating];
                self.indicator.hidden = NO;
                
                break;
                
            case SKPaymentTransactionStatePurchased:
                
                [self.indicator stopAnimating];
                self.indicator.hidden = YES;
                
                [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your purchase was completed successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                break;
                
            case SKPaymentTransactionStateRestored:
                
                [self.indicator stopAnimating];
                self.indicator.hidden = YES;
                
                [[[UIAlertView alloc] initWithTitle:@"Success!" message:@"Your purchase was restored successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                break;
                
            case SKPaymentTransactionStateFailed:
                
                if (transaction.error.code != SKErrorPaymentCancelled) {
                    
                    NSLog(@"An error has occurred");
                    
                }
                
                [self.indicator stopAnimating];
                self.indicator.hidden = YES;
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
            default:
                break;
        }
        
    }
    
}

@end
