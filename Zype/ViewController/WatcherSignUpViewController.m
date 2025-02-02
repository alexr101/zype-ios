//
//  WatcherSignUpViewController.m
//  Zype
//
//  Created by Christian on 26.03.19.
//

#import "WatcherSignUpViewController.h"
#import "ACSDataManager.h"
#import "SVProgressHUD.h"
#import "ACSTokenManager.h"
#import "ACSAlertViewManager.h"
#import "UIUtil.h"
#import "NSString+AC.h"
#import "ACPurchaseManager.h"
#import "UIView+UIView_CustomizeTheme.h"
#import "CustomizeThemeTextField.h"
#import "WatcherSignInViewController.h"

@interface WatcherSignUpViewController ()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet CustomizeThemeTextField *emailField;
@property (strong, nonatomic) IBOutlet CustomizeThemeTextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) IBOutlet UIView *credentialContainerView;
@property (strong, nonatomic) IBOutlet UIView *separateLineView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIButton *signinButton;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fieldViewBottomConstraintY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *centerCredentialsConstraintY;


@end

@implementation WatcherSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    [self setupConfiguration];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConfiguration {
    [self.createButton tintCustomizeTheme];
    [self customizeAppearance];
    [self.createButton round:kViewCornerRounded];
    [self.credentialContainerView round:kViewCornerRounded];
    [self.credentialContainerView borderCustomizeTheme];
    [self.emailField setAttributePlaceholder:@"Email"];
    [self.passwordField setAttributePlaceholder:@"Password"];
    UIColor * titleColor = (kAppColorLight) ? kDarkThemeBackgroundColor : [UIColor whiteColor];
    self.titleLabel.textColor = titleColor;
    
    self.infoLabel.text = [NSString stringWithFormat:@"Please enter a valid email and password to create an account. Using this account, you are able to watch videos on any device"];
    
    UIColor * termsTextColor = (kAppColorLight) ? kLightTintColor : kDarkTintColor;
    NSDictionary * attributes = @{NSForegroundColorAttributeName: termsTextColor,
                                  NSFontAttributeName: [UIFont fontWithName:@"Roboto-Medium" size:12.0f]};
    NSMutableAttributedString * attrstring = [[NSMutableAttributedString alloc] initWithString:@"By clicking Create Account, you agree to our " attributes:@{NSForegroundColorAttributeName: kUniversalGray,
                                                                                                                                                NSFontAttributeName: [UIFont fontWithName:@"Roboto-Regular" size:12.0f]}];
    NSAttributedString * signupText = [[NSAttributedString alloc] initWithString:@"Terms of Service and Privacy" attributes:attributes];
    [attrstring appendAttributedString:signupText];
    
    UIColor * signInColor = (kAppColorLight) ? kLightTintColor : kDarkTintColor;
    NSDictionary * signInAttributes = @{NSForegroundColorAttributeName: signInColor,
                                  NSFontAttributeName: [UIFont systemFontOfSize:12.0f weight:UIFontWeightMedium]};
    NSMutableAttributedString * attrstringFirstPart = [[NSMutableAttributedString alloc] initWithString:@"Already have an account? " attributes:@{NSForegroundColorAttributeName: kUniversalGray}];
    NSAttributedString * signinText = [[NSAttributedString alloc] initWithString:@"Sign in" attributes:signInAttributes];
    [attrstringFirstPart appendAttributedString:signinText];
    [self.signinButton setAttributedTitle:attrstringFirstPart forState:UIControlStateNormal];
    
    NSString *arrowImageString = (kAppColorLight) ? @"arrow-light" : @"arrow-black";
    [self.arrowImageView setImage:[UIImage imageNamed:arrowImageString]];
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSNumber *durationValue = info[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = info[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    //
    // Create animation.
    
    self.fieldViewBottomConstraintY.constant = kbSize.height;
    
    CGFloat heightArea = self.view.frame.size.height - kbSize.height;
    CGFloat bottomPadding = 80.0f;
    CGFloat y = (heightArea / 2) - (self.credentialContainerView.frame.size.height / 2) - bottomPadding;
    self.centerCredentialsConstraintY.constant = y;
    
    
    void (^animations)(void) = ^() {
        [self.view layoutIfNeeded];
    };
    
    //
    // Begin animation.
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.fieldViewBottomConstraintY.constant = 80;
    self.centerCredentialsConstraintY.constant = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Actions

- (IBAction)createLogin:(id)sender {
    NSString *errorString = [self validateCredentials];
    if (errorString) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:errorString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:nil];
    } else {
        [self registerWithUsername:self.emailField.text WithPassword:self.passwordField.text];
    }
}

- (IBAction)showSigninController:(id)sender {
    if ([self.presentingViewController isKindOfClass:[WatcherSignInViewController class]]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [UIUtil showWatcherSignInViewFromViewController:self];
    }
}


- (IBAction)cancelController:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)dismissControllers {
    if (self.presentingViewController.presentingViewController) {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)showTermsOfUse:(id)sender {
    [UIUtil showTermOfServicesFromViewController:self];
}


- (NSString *)validateCredentials {
    NSString *errorString;
    
    if ([self.emailField.text  isEqual: @""] || [self.passwordField.text  isEqual: @""]) {
        return @"Please fill out the missing fields and try again.";
    }
    
    NSString *trimmedPassword = [self.passwordField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![self.passwordField.text isEqualToString:trimmedPassword]) {
        return @"Password cannot include spaces.";
    }
    
    if (![self.emailField.text validateEmail]) {
        return @"Please enter a valid email address and try again.";
    }
    
    return errorString;
}

#pragma mark - Register

- (void)registerWithUsername:(NSString *)username WithPassword:(NSString *)password {
    [SVProgressHUD show];
    [ACSDataManager registerWithUsername:username password:password block:^(BOOL success, NSError *error) {
        if (success == YES) {
            [ACSDataManager loginWithUsername:username password:password block:^(BOOL success, NSError *error) {
                if (success) {
                    [SVProgressHUD dismiss];
                    if (self != nil) {
                        
                        [self dismissControllers];
                        if (self.planDelegate != nil) {
                            [self.planDelegate subscriptionSignInDone];
                        }
                        
                    }
                } else {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            [ACSAlertViewManager showAlertWithTitle:kString_TitleSignInFail WithMessage:kString_MessageRegisterFail];
        }
        
    }];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
