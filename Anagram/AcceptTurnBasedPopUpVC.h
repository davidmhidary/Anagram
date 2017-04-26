//
//  AcceptTurnBasedPopUpVC.h
//  Anagram
//
//  Created by Ashok Choudhary on 06/09/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcceptTurnBasedPopUpVC : UIViewController
{
    NSDictionary *infoDict;

}
@property(nonatomic,strong)NSDictionary *dictPayload;
@property(nonatomic,strong)IBOutlet UILabel *lablName;
@end
