//
//  OBAppDelegate.m
//  ColorGraph
//
//  Created by Ondra Beneš on 12/13/11.
//  Copyright (c) 2011 FIT VUTBR. All rights reserved.
//

#import "OBAppDelegate.h"
#import "OBEvolution.h"

@implementation OBAppDelegate

@synthesize window = _window;
@synthesize progressWindow, progress, resultWindow;
@synthesize populationSize, generations, bestIndividuals;
@synthesize fitnessLabel, progressLabel, fitnessResult;
@synthesize filename, mutationProperty, mutationSwitch;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	// basic evolution settings (fill in GUI)
	self.generations = 500;
	self.populationSize = 100;
	self.bestIndividuals = self.populationSize/4;
	self.mutationProperty = 0.1f;
	self.mutationSwitch = 0.1f;

}

- (IBAction)runEvolution:(id)sender {
	
	// check if file was chosen
//	if (self.filename == nil || self.filename.length == 0) {
//		[self performSelector:@selector(openFile:)];
//	}
	
	// run sheet with progress
	[NSApp beginSheet:progressWindow modalForWindow:_window modalDelegate:self didEndSelector:nil contextInfo:nil];
	
	// run evolution
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
	
	// progress bar settings
	[self.progress usesThreadedAnimation];
}

- (void)openFile:(id)sender {
	
	// show panel for file choosing
	NSOpenPanel *op = [NSOpenPanel openPanel];
    if ([op runModal] == NSOKButton) {
		NSURL *fileUrl = [op URL];
		self.filename = [fileUrl absoluteString];
		NSLog(@"Opening file %@", self.filename);
	}
}

- (void)showResultForFitness:(NSUInteger)fitness {
	
	// hide window with progress bar and display results
	[self stopEvolution:nil];
	self.fitnessResult.stringValue = [NSString stringWithFormat:@"%ld", fitness];
	[NSApp beginSheet:resultWindow modalForWindow:_window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)dismissResults:(id)sender {
	
	// dismiss window with results
	[NSApp endSheet:resultWindow returnCode:0];
	[resultWindow orderOut:self];
}

- (IBAction)stopEvolution:(id)sender {
	
	// dismiss window with progress
	[NSApp endSheet:progressWindow returnCode:0];
	[progressWindow orderOut:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	
	// closing app
	return YES;
}

- (void)dealloc {
    [super dealloc];
}

@end
