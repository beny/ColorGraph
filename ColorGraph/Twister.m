//
//  Twister.m
//  ColoringGraph
//
//  Created by Ondra Beneš on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Twister.h"

#define XOR ^ //i XOR j => two equal bits yields 0 bit, two unequal bits yields 1 bit
#define bitAND & // two 1 bits yields a 1 bit, everything else a 0 bit
#define bitOR | //  two 0 bits yields a 0 bit, everything else a 1 bit
#define leftBitShift << // i << n => shift i by n places to the left. Vacant bits are filled with 0, excess bits are dropped
#define rightBitShift >> // i << n => shift i by n places to the right. Shifted bits are dropped

static NSUInteger bitMaskUnity = 0xffffffffUL; //wordsize: 32 bits (32 times 1)
static NSUInteger bitMaskHighestBit = 0x80000000UL; //most significant bit 
static NSUInteger bitMaskLowerBits = 0x7FFFFFFFUL; // last (wordsize-1)-number of bits => last 31 bits

@implementation Twister
/**
 Random number generator based on the Mersenne Twister
 
 see http://en.wikipedia.org/wiki/Mersenne_twister#Pseudocode
 see http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/MT2002/CODES/mt19937ar.c
 */

#pragma mark -
#pragma mark init
-(id) init {
	self = [super init];
	if (self != nil) 
	{
		[self initializeGenerator:0];
	}
	return self;
}


#pragma mark -
#pragma mark seed
-(BOOL) initializeGenerator:(NSUInteger)seed {
	/**
	 If seed is 0, then the number of seconds since 1970 is used as seed.
	 */
	
	if (seed == 0) {
		seed = [[NSDate date] timeIntervalSince1970];
	}	
	mersenneTwister[0] = (unsigned)seed;
	
	
	for (int i = 1; i < lengthMersenneTwister; i++) {
		mersenneTwister[i] = bitMaskUnity & (1812433253 * (mersenneTwister[i-1] XOR (mersenneTwister[i-1] rightBitShift 30)) + i);
	}
	
	generationCounter = 0;
	return YES;
}

-(BOOL) regenerateMersenneTwister {
	/** 
	 Every "lengthMersenneTwister" random numbers, the bit repository (i.e. mersenneTwister[]) has to be regenerated
	 */
	for (int i = 0; i < lengthMersenneTwister; i++) 
	{
		NSUInteger y = (bitMaskHighestBit & mersenneTwister[i]) + (bitMaskLowerBits & (mersenneTwister[i+1] % lengthMersenneTwister));
		int index = (i+397) % lengthMersenneTwister;
		mersenneTwister[i] = mersenneTwister[index] XOR (y rightBitShift 1);
		if ((y % 2) == 1) //y is odd
		{
			mersenneTwister[i] = mersenneTwister[i] XOR (0x9908b0dfUL);	
		}		
	}
	generationCounter = 0;
	return YES;
}

#pragma mark -
#pragma mark seedbank
-(NSArray *) mersenneTwister {
	NSMutableArray *output = [NSMutableArray arrayWithCapacity:lengthMersenneTwister];
	for (int i = 0; i < lengthMersenneTwister; i++) {
		[output addObject:[NSNumber numberWithInt:mersenneTwister[i]]];
	}
	return [[output copy] autorelease];
}
-(NSNumber *) generation {
	return [NSNumber numberWithInt:generationCounter];
}

-(BOOL) setMersenneTwister:(NSArray *)seed generation:(NSNumber *)generation {	
	BOOL succes = ([seed count] == lengthMersenneTwister);
	if (succes) {
		for (int i = 0; i < lengthMersenneTwister; i++) {
			mersenneTwister[i] = [[seed objectAtIndex:i] intValue];
		}
		generationCounter = [generation intValue];
	}
	return succes;
}


#pragma mark -
#pragma mark random primitives
//BOOL
-(BOOL) randomBOOLValue {
	return ([self randomDoubleValue] > 0.5) ? YES : NO;
}

//int
-(NSUInteger) randomUnsignedIntValue { //range [0, 2^lengthMersenneTwister - 1]
	if (generationCounter == 0) {
		[self regenerateMersenneTwister];
	}
	
	NSUInteger output = mersenneTwister[generationCounter];
	output = output XOR (output rightBitShift 11);
	output = output XOR ((output leftBitShift 7) & 0x9d2c5680UL);
	output = output XOR ((output leftBitShift 15) & 0xefc60000UL);
	output = output XOR (output rightBitShift 18);
	
	generationCounter = (generationCounter + 1) % lengthMersenneTwister;
	return output;
}
-(int) randomIntValue  {
	return (int)([self randomUnsignedIntValue] - (bitMaskUnity/2));
}
-(int) randomIntValueBetweenStart:(int)start andStop:(int)stop {
	int range = ((stop - start) > 0) ? (stop - start) + 1 : (stop - start) - 1;
	return (int)(start + roundtol([self randomDoubleValue] * range - 0.5));
}

//double
-(double) randomDoubleValue { //range [0,1] 
	return (double)[self randomUnsignedIntValue]*(1.0/bitMaskUnity);
}

-(double) randomDoubleValueBetweenStart:(double)start andStop:(double)stop {
	
	double range = ((stop - start) > 0) ? (stop - start) + 1 : (stop - start) - 1;
	return (start + [self randomDoubleValue] * range - 0.5);
}

#pragma mark -
#pragma mark random numbers
//BOOL
-(NSNumber *) randomBOOLNumber {
	return [NSNumber numberWithBool:[self randomBOOLValue]];
}

//int
-(NSNumber *) randomUnsignedIntNumber {
	return [NSNumber numberWithUnsignedInt:(unsigned)[self randomUnsignedIntValue]];
}

-(NSNumber *)randomUnsignedIntNumberStart:(unsigned)start andStop:(unsigned)stop{	
	return [NSNumber numberWithInt:(unsigned)[self randomIntValueBetweenStart:start andStop:stop]];
}

-(NSNumber *) randomIntNumber {
	return [NSNumber numberWithInt:[self randomIntValue]];
}

-(NSNumber *) randomIntNumberBetweenStart:(int)start andStop:(int) stop {	
	return [NSNumber numberWithInt:[self randomIntValueBetweenStart:start andStop:stop]];
}

//Double
-(NSNumber *) randomDoubleNumber {
	return [NSNumber numberWithDouble:[self randomDoubleValue]];
}
-(NSNumber *) randomDoubleNumberBetweenStart:(double) start andStop:(double)stop {
	return [NSNumber numberWithDouble:[self randomDoubleValueBetweenStart:start andStop:stop]];
}

#pragma mark -
#pragma mark primitive datatypes 
-(void) printSizeOfPrimitiveTypes {
	int i = 1;
	NSLog(@"Primitive sizes in bytes (1 byte = 8 bit):");
	NSLog(@"%d The size of a char is: %lu.", i++, sizeof(char));
	NSLog(@"%d The size of short is: %lu.", i++, sizeof(short));
	NSLog(@"%d The size of int is: %lu.",  i++, sizeof(int));
	NSLog(@"%d The size of long is: %lu.",  i++, sizeof(long));
	NSLog(@"%d The size of long long is: %lu.",  i++, sizeof(long long));
	NSLog(@"%d The size of a unsigned char is: %lu.",  i++, sizeof(unsigned char));
	NSLog(@"%d The size of unsigned short is: %lu.",  i++, sizeof(unsigned short));
	NSLog(@"%d The size of unsigned int is: %lu.",  i++, sizeof(unsigned int));
	NSLog(@"%d The size of unsigned long is: %lu.",  i++, sizeof(unsigned long));
	NSLog(@"%d The size of unsigned long long is: %lu.",  i++, sizeof(unsigned long long));
	NSLog(@"%d The size of a float is: %lu.",  i++, sizeof(float));
	NSLog(@"%d The size of a double is %lu.",  i++, sizeof(double));
}

#pragma mark -
#pragma mark test
-(void) testAlpha {
	int range = 50;
	for (int i = 0; i < 5; i++) {
		NSLog(@"loop %i",i);
		NSLog(@"random int %lu",[self randomUnsignedIntValue]);
		NSLog(@"random int %i range 0:%i",[self randomIntValueBetweenStart:0 andStop:range],range);
		NSLog(@"random int %i range -%i:%i",[self randomIntValueBetweenStart:-1*range andStop:range],range,range);
		NSLog(@"random double %e",[self randomDoubleValue]);
		NSLog(@"random double %e range 0:%i",[self randomDoubleValueBetweenStart:0 andStop:range],range);
		NSLog(@"random double %e range -%i:%i",[self randomDoubleValueBetweenStart:-1*range andStop:range],range,range);
		NSString *flag = ([self randomBOOLValue]) ? @"Y" : @"N";
		NSLog(@"random flag %@",flag);
	}
}
-(void) testBeta {
	/**
	 Expected outcome: an equal distribution of random integers between the start and stop values. Start and stop are included.
	 */
	int start = 50;
	int stop = 61;
	
	if (stop < start)
		return;
	
	int range = stop - start;
	
	int histogram[range];
	for (int i = 0; i < range; i++) {
		histogram[i] = 0;
	}	
	
	for (int i = 0; i < 5000; i++) {
		int index = [self randomIntValueBetweenStart:start andStop:stop];
		histogram[index-start] = histogram[index-start] + 1;		
	}
	
	NSLog(@"Frequency distribution");
	for (int i = 0; i < range; i++) {
		NSLog(@"%i, %i",start+i,histogram[i]);
	}
}
-(void) testGamma {
	/**
	 Expected outcome: a distribution close to 50-50%. 
	 */
	int truthOrDare[2];
	truthOrDare[0] = 0;
	truthOrDare[1] = 0;
	
	for (int i = 0; i < 5000; i++) {
		int index = ([self randomBOOLValue]) ? 1 : 0;
		truthOrDare[index] = truthOrDare[index] + 1;		
	}
	
	NSLog(@"Truth, %i",truthOrDare[0]);
	NSLog(@"Dare, %i",truthOrDare[1]);
}

-(void) runTests {
	NSLog(@"start");
	[self testAlpha];
	[self testBeta];
	[self testGamma];
	NSLog(@"end");
}

@end
