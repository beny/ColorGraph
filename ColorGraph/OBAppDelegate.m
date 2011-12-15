//
//  OBAppDelegate.m
//  ColorGraph
//
//  Created by Ondra Beneš on 12/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OBAppDelegate.h"
#import "OBEvolution.h"

@implementation OBAppDelegate

@synthesize window = _window;
@synthesize progressWindow, progress, resultWindow;
@synthesize populationSize, generations, bestIndividuals;
@synthesize fitnessLabel, progressLabel, fitnessResult;
@synthesize filename, mutationProperty;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	self.generations = 500;
	self.populationSize = 10;
	self.bestIndividuals = self.populationSize/2;
	self.mutationProperty = 0.1f;

}

- (IBAction)runEvolution:(id)sender {
	
//	if (self.filename == nil || self.filename.length == 0) {
//		[self performSelector:@selector(openFile:)];
//	}
	
	[NSApp beginSheet:progressWindow modalForWindow:_window modalDelegate:self didEndSelector:nil contextInfo:nil];
	
	OBEvolution *evolution = [[[OBEvolution alloc] init] autorelease];
	evolution.delegate = self;
	evolution.progressLabel = self.progressLabel;
	evolution.progressIndicator = self.progress;
	evolution.generations = self.generations;
	evolution.populationSize = self.populationSize;
	evolution.bestIndividualsCount = self.bestIndividuals;
	evolution.bestFitness = self.fitnessLabel;
	[evolution runEvolution];
}

- (void)awakeFromNib {
	[self.progress usesThreadedAnimation];
}

- (void)openFile:(id)sender {
	NSOpenPanel *op = [NSOpenPanel openPanel];
    if ([op runModal] == NSOKButton) {
		NSURL *fileUrl = [op URL];
		self.filename = [fileUrl absoluteString];
		NSLog(@"Opening file %@", self.filename);
	}
}

- (void)showResultForFitness:(NSUInteger)fitness {
	
	[self stopEvolution:nil];
	
	self.fitnessResult.stringValue = [NSString stringWithFormat:@"%ld", fitness];
	[NSApp beginSheet:resultWindow modalForWindow:_window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)dismissResults:(id)sender {
	[NSApp endSheet:resultWindow returnCode:0];
	[resultWindow orderOut:self];
}

- (IBAction)stopEvolution:(id)sender {
	
	[NSApp endSheet:progressWindow returnCode:0];
	[progressWindow orderOut:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (void)dealloc {
    [super dealloc];
}

@end
