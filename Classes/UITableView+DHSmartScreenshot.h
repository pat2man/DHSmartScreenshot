//
//  UITableView+DHSmartScreenshot.h
//  TableViewScreenshots
//
//  Created by Hernandez Alvarez, David on 11/28/13.
//  Copyright (c) 2013 David Hernandez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (DHSmartScreenshot)

- (UIImage *)screenshot;

- (UIImage*)screenshotWithScale:(CGFloat)scale;

- (UIImage *)screenshotOfCellAtIndexPath:(NSIndexPath *)indexPath scale:(CGFloat)scale;

- (UIImage *)screenshotOfHeaderViewAtSection:(NSUInteger)section scale:(CGFloat)scale;

- (UIImage *)screenshotOfFooterViewAtSection:(NSUInteger)section scale:(CGFloat)scale;

- (UIImage *)screenshotExcludingAllHeaders:(BOOL)withoutHeaders
					   excludingAllFooters:(BOOL)withoutFooters
						  excludingAllRows:(BOOL)withoutRows
                                     scale:(CGFloat)scale;

- (UIImage *)screenshotExcludingHeadersAtSections:(NSSet *)headerSections
					   excludingFootersAtSections:(NSSet *)footerSections
						excludingRowsAtIndexPaths:(NSSet *)indexPaths
                                            scale:(CGFloat)scale;

- (UIImage *)screenshotOfHeadersAtSections:(NSSet *)headerSections
						 footersAtSections:(NSSet *)footerSections
						  rowsAtIndexPaths:(NSSet *)indexPaths
                                     scale:(CGFloat)scale;

@end

