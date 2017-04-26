//
//  WordOfTheDayVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 20/04/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordOfTheDayVC : UIViewController
{
    IBOutlet UIView *viewWOD;

    //to show the number of the
    IBOutlet UILabel *lblWordPoints;
    IBOutlet UILabel *lblWOD;
    

}
@property (nonatomic,strong)NSString *strWordOfDay;
@end
