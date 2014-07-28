//
//  UITableView+DHSmartScreenshot.m
//  TableViewScreenshots
//
//  Created by Hernandez Alvarez, David on 11/28/13.
//  Copyright (c) 2013 David Hernandez. All rights reserved.
//

#import "UITableView+DHSmartScreenshot.h"
#import "UIView+DHSmartScreenshot.h"
#import "UIImage+DHImageAdditions.h"

@implementation UITableView (DHSmartScreenshot)

- (UIImage *)screenshot
{
	return [self screenshotWithScale:self.window.screen.scale ?: 0.0];
}

- (UIImage*)screenshotWithScale:(CGFloat)scale {
	return [self screenshotExcludingHeadersAtSections:nil
						   excludingFootersAtSections:nil
							excludingRowsAtIndexPaths:nil
                                                scale:scale];
}

- (UIImage *)screenshotOfCellAtIndexPath:(NSIndexPath *)indexPath
                                   scale:(CGFloat)scale
{
	UIImage *cellScreenshot = nil;
	
	// Current tableview offset
	CGPoint currTableViewOffset = self.contentOffset;
	
	// First, scroll the tableview so the cell would be rendered on the view and able to screenshot'it
	[self scrollToRowAtIndexPath:indexPath
				atScrollPosition:UITableViewScrollPositionTop
						animated:NO];
	
	// Take the screenshot
	cellScreenshot = [[self cellForRowAtIndexPath:indexPath] screenshot];
	
	// scroll back to the original offset
	[self setContentOffset:currTableViewOffset animated:NO];
	
	return cellScreenshot;
}

- (UIImage *)screenshotOfHeaderViewWithScale:(CGFloat)scale
{
	CGPoint originalOffset = [self contentOffset];
	CGRect headerRect = [self tableHeaderView].frame;
	
	[self scrollRectToVisible:headerRect animated:NO];
	UIImage *headerScreenshot = [self screenshotForCroppingRect:headerRect scale:scale];
	[self setContentOffset:originalOffset animated:NO];
	
	return headerScreenshot;
}

- (UIImage *)screenshotOfFooterViewWithScale:(CGFloat)scale
{
	CGPoint originalOffset = [self contentOffset];
	CGRect footerRect = [self tableFooterView].frame;
	
	[self scrollRectToVisible:footerRect animated:NO];
	UIImage *footerScreenshot = [self screenshotForCroppingRect:footerRect scale:scale];
	[self setContentOffset:originalOffset animated:NO];
	
	return footerScreenshot;
}

- (UIImage *)screenshotOfHeaderViewAtSection:(NSUInteger)section scale:(CGFloat)scale
{
	CGPoint originalOffset = [self contentOffset];
	CGRect headerRect = [self rectForHeaderInSection:section];
	
	[self scrollRectToVisible:headerRect animated:NO];
	UIImage *headerScreenshot = [self screenshotForCroppingRect:headerRect scale:scale];
	[self setContentOffset:originalOffset animated:NO];
	
	return headerScreenshot;
}

- (UIImage *)screenshotOfFooterViewAtSection:(NSUInteger)section scale:(CGFloat)scale
{
	CGPoint originalOffset = [self contentOffset];
	CGRect footerRect = [self rectForFooterInSection:section];
	
	[self scrollRectToVisible:footerRect animated:NO];
	UIImage *footerScreenshot = [self screenshotForCroppingRect:footerRect scale:scale];
	[self setContentOffset:originalOffset animated:NO];
	
	return footerScreenshot;
}

- (UIImage *)screenshotExcludingAllHeaders:(BOOL)withoutHeaders
					   excludingAllFooters:(BOOL)withoutFooters
						  excludingAllRows:(BOOL)withoutRows
                                     scale:(CGFloat)scale
{
	NSArray *excludedHeadersOrFootersSections = nil;
	if (withoutHeaders || withoutFooters) excludedHeadersOrFootersSections = [self allSectionsIndexes];
	
	NSArray *excludedRows = nil;
	if (withoutRows) excludedRows = [self allRowsIndexPaths];
	
	return [self screenshotExcludingHeadersAtSections:(withoutHeaders)?[NSSet setWithArray:excludedHeadersOrFootersSections]:nil
						   excludingFootersAtSections:(withoutFooters)?[NSSet setWithArray:excludedHeadersOrFootersSections]:nil
							excludingRowsAtIndexPaths:(withoutRows)?[NSSet setWithArray:excludedRows]:nil
                                                scale:scale];
}

- (UIImage *)screenshotExcludingHeadersAtSections:(NSSet *)excludedHeaderSections
					   excludingFootersAtSections:(NSSet *)excludedFooterSections
						excludingRowsAtIndexPaths:(NSSet *)excludedIndexPaths
                                            scale:(CGFloat)scale
{
	NSMutableArray *screenshots = [NSMutableArray array];
	// Header Screenshot
	UIImage *headerScreenshot = [self screenshotOfHeaderViewWithScale:scale];
	if (headerScreenshot) [screenshots addObject:headerScreenshot];
	for (int section=0; section<self.numberOfSections; section++) {
		// Header Screenshot
		UIImage *headerScreenshot = [self screenshotOfHeaderViewAtSection:section excludedHeaderSections:excludedHeaderSections scale:scale];
		if (headerScreenshot) [screenshots addObject:headerScreenshot];
		
		// Screenshot of every cell of this section
		for (int row=0; row<[self numberOfRowsInSection:section]; row++) {
			NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
			UIImage *cellScreenshot = [self screenshotOfCellAtIndexPath:cellIndexPath excludedIndexPaths:excludedIndexPaths];
			if (cellScreenshot) [screenshots addObject:cellScreenshot];
		}
		
		// Footer Screenshot
		UIImage *footerScreenshot = [self screenshotOfFooterViewAtSection:section excludedFooterSections:excludedFooterSections scale:scale];
		if (footerScreenshot) [screenshots addObject:footerScreenshot];
	}
	UIImage *footerScreenshot = [self screenshotOfFooterViewWithScale:scale];
	if (footerScreenshot) [screenshots addObject:footerScreenshot];
	return [UIImage verticalImageFromArray:screenshots scale:scale];
}

- (UIImage *)screenshotOfHeadersAtSections:(NSSet *)includedHeaderSections
						 footersAtSections:(NSSet *)includedFooterSections
						  rowsAtIndexPaths:(NSSet *)includedIndexPaths
                                     scale:(CGFloat)scale
{
	NSMutableArray *screenshots = [NSMutableArray array];
	
	for (int section=0; section<self.numberOfSections; section++) {
		// Header Screenshot
		UIImage *headerScreenshot = [self screenshotOfHeaderViewAtSection:section includedHeaderSections:includedHeaderSections scale:scale];
		if (headerScreenshot) [screenshots addObject:headerScreenshot];
		
		// Screenshot of every cell of the current section
		for (int row=0; row<[self numberOfRowsInSection:section]; row++) {
			NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
			UIImage *cellScreenshot = [self screenshotOfCellAtIndexPath:cellIndexPath includedIndexPaths:includedIndexPaths scale:scale];
			if (cellScreenshot) [screenshots addObject:cellScreenshot];
		}
		
		// Footer Screenshot
		UIImage *footerScreenshot = [self screenshotOfFooterViewAtSection:section includedFooterSections:includedFooterSections scale:scale];
		if (footerScreenshot) [screenshots addObject:footerScreenshot];
	}
	return [UIImage verticalImageFromArray:screenshots scale:scale];
}

#pragma mark - Hard Working for Screenshots

- (UIImage *)screenshotOfCellAtIndexPath:(NSIndexPath *)indexPath excludedIndexPaths:(NSSet *)excludedIndexPaths
{
	if ([excludedIndexPaths containsObject:indexPath]) return nil;
	return [self screenshotOfCellAtIndexPath:indexPath scale:self.window.screen.scale];
}

- (UIImage *)screenshotOfHeaderViewAtSection:(NSUInteger)section excludedHeaderSections:(NSSet *)excludedHeaderSections scale:(CGFloat)scale
{
	if ([excludedHeaderSections containsObject:@(section)]) return nil;
	
	UIImage *sectionScreenshot = nil;
	sectionScreenshot = [self screenshotOfHeaderViewAtSection:section scale:scale];
	if (! sectionScreenshot) {
		sectionScreenshot = [self blankScreenshotOfHeaderAtSection:section];
	}
	return sectionScreenshot;
}

- (UIImage *)screenshotOfFooterViewAtSection:(NSUInteger)section excludedFooterSections:(NSSet *)excludedFooterSections scale:(CGFloat)scale
{
	if ([excludedFooterSections containsObject:@(section)]) return nil;
	
	UIImage *sectionScreenshot = nil;
	sectionScreenshot = [self screenshotOfFooterViewAtSection:section scale:scale];
	if (! sectionScreenshot) {
		sectionScreenshot = [self blankScreenshotOfFooterAtSection:section];
	}
	return sectionScreenshot;
}

- (UIImage *)screenshotOfCellAtIndexPath:(NSIndexPath *)indexPath includedIndexPaths:(NSSet *)includedIndexPaths scale:(CGFloat)scale
{
	if (![includedIndexPaths containsObject:indexPath]) return nil;
	return [self screenshotOfCellAtIndexPath:indexPath scale:scale];
}

- (UIImage *)screenshotOfHeaderViewAtSection:(NSUInteger)section includedHeaderSections:(NSSet *)includedHeaderSections scale:(CGFloat)scale
{
	if (![includedHeaderSections containsObject:@(section)]) return nil;
	
	UIImage *sectionScreenshot = nil;
	sectionScreenshot = [self screenshotOfHeaderViewAtSection:section scale:scale];
	if (! sectionScreenshot) {
		sectionScreenshot = [self blankScreenshotOfHeaderAtSection:section];
	}
	return sectionScreenshot;
}

- (UIImage *)screenshotOfFooterViewAtSection:(NSUInteger)section includedFooterSections:(NSSet *)includedFooterSections scale:(CGFloat)scale
{
	if (![includedFooterSections containsObject:@(section)]) return nil;
	
	UIImage *sectionScreenshot = nil;
	sectionScreenshot = [self screenshotOfFooterViewAtSection:section scale:scale];
	if (! sectionScreenshot) {
		sectionScreenshot = [self blankScreenshotOfFooterAtSection:section];
	}
	return sectionScreenshot;
}

#pragma mark - Blank Screenshots

- (UIImage *)blankScreenshotOfHeaderAtSection:(NSUInteger)section
{
	CGSize headerRectSize = CGSizeMake(self.bounds.size.width, [self rectForHeaderInSection:section].size.height);
	return [UIImage imageWithColor:[UIColor clearColor] size:headerRectSize];
}

- (UIImage *)blankScreenshotOfFooterAtSection:(NSUInteger)section
{
	CGSize footerRectSize = CGSizeMake(self.bounds.size.width, [self rectForFooterInSection:section].size.height);
	return [UIImage imageWithColor:[UIColor clearColor] size:footerRectSize];
}

#pragma mark - All Headers / Footers sections

- (NSArray *)allSectionsIndexes
{
	long numOfSections = [self numberOfSections];
	NSMutableArray *allSectionsIndexes = [NSMutableArray array];
	for (int section=0; section < numOfSections; section++) {
		[allSectionsIndexes addObject:@(section)];
	}
	return allSectionsIndexes;
}

#pragma mark - All Rows Index Paths

- (NSArray *)allRowsIndexPaths
{
	NSMutableArray *allRowsIndexPaths = [NSMutableArray array];
	for (NSNumber *sectionIdx in [self allSectionsIndexes]) {
		for (int rowNum=0; rowNum<[self numberOfRowsInSection:[sectionIdx unsignedIntegerValue]]; rowNum++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowNum inSection:[sectionIdx unsignedIntegerValue]];
			[allRowsIndexPaths addObject:indexPath];
		}
	}
	return allRowsIndexPaths;
}
@end
