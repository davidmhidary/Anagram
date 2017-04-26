//
//  TileView.h
//  Anagram
//
//  Created by Ashok Choudhary on 06/05/16.
//  Copyright © 2016 squarebits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TileView : UIView




@property int Id;
@property (nonatomic,strong) IBOutlet UILabel *lblT;
@property BOOL isSelected;
@property (nonatomic,strong) NSMutableDictionary *dictTileFrame;
@property (nonatomic,strong) NSMutableDictionary *dictCharData;

//this tag will used to get the super view of the tile
@property NSInteger my_TAG;

@property BOOL isTilesBelongsToScrollView;
@property BOOL isUpparScrollWord,isLowerScrollWord;

+ (TileView*)initWithFrame:(CGRect)frame;


@end
