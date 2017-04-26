//
//  WinsAndLosesCell.h
//  Anagram
//
//  Created by Ashok Choudhary on 31/08/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WinsAndLosesCell : UITableViewCell
{
    
}
@property(nonatomic,strong)IBOutlet UILabel      *lblPlayerName,*lblScore,*lblDate;
@property(nonatomic,strong)IBOutlet UILabel      *lblOponentName,*lblOponentScore;
@property(nonatomic,strong)IBOutlet UIImageView  *imgUserTurn,*imgOpponent;


@end
