//
//  Copyright (c) 2013 Martin Johannesson
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//  (MIT License)
//

#import <Foundation/Foundation.h>

@class MJPBXBuildFile;
@class MJPBXFileReference;
@class MJPBXFrameworksBuildPhase;
@class MJPBXGroup;
@class MJPBXNativeTarget;
@class MJPBXProject;
@class MJPBXResourcesBuildPhase;
@class MJPBXSourcesBuildPhase;
@class MJPBXVariantGroup;
@class MJPBXContainerItemProxy;
@class MJPBXReferenceProxy;
@class MJPBXTargetDependency;
@class MJPBXShellScriptBuildPhase;
@class MJXCBuildConfiguration;
@class MJXCConfigurationList;

@interface MJProject : NSObject

@property (nonatomic, readonly, strong) NSDictionary *specification;

@property (nonatomic, readonly, copy) NSNumber *archiveVersion;
@property (nonatomic, readonly, strong) NSDictionary *classes;
@property (nonatomic, readonly, copy) NSNumber *objectVersion;
@property (nonatomic, readonly, strong) NSDictionary *objects;
@property (nonatomic, readonly, copy) NSString *rootObject;

@property (nonatomic, readonly, strong) NSDictionary *allObjects;

@property (nonatomic, readonly, strong) NSDictionary *buildFiles;
@property (nonatomic, readonly, strong) NSDictionary *fileReferences;
@property (nonatomic, readonly, strong) NSDictionary *frameworksBuildPhases;
@property (nonatomic, readonly, strong) NSDictionary *groups;
@property (nonatomic, readonly, strong) NSDictionary *nativeTargets;
@property (nonatomic, readonly, strong) NSDictionary *projects;
@property (nonatomic, readonly, strong) NSDictionary *resourcesBuildPhases;
@property (nonatomic, readonly, strong) NSDictionary *sourcesBuildPhases;
@property (nonatomic, readonly, strong) NSDictionary *variantGroups;
@property (nonatomic, readonly, strong) NSDictionary *containerItemProxies;
@property (nonatomic, readonly, strong) NSDictionary *referenceProxies;
@property (nonatomic, readonly, strong) NSDictionary *targetDependencies;
@property (nonatomic, readonly, strong) NSDictionary *shellScriptBuildPhases;
@property (nonatomic, readonly, strong) NSDictionary *buildConfigurations;
@property (nonatomic, readonly, strong) NSDictionary *configurationLists;

+ (MJProject *)projectWithContentsOfURL:(NSURL *)url
                                  error:(__autoreleasing NSError **)error;

- (MJPBXBuildFile *)buildFileById:(NSString *)uuid;
- (MJPBXFileReference *)fileReferenceById:(NSString *)uuid;
- (MJPBXFrameworksBuildPhase *)frameworksBuildPhaseById:(NSString *)uuid;
- (MJPBXGroup *)groupById:(NSString *)uuid;
- (MJPBXNativeTarget *)nativeTargetById:(NSString *)uuid;
- (MJPBXProject *)projectById:(NSString *)uuid;
- (MJPBXResourcesBuildPhase *)resourcesBuildPhaseById:(NSString *)uuid;
- (MJPBXSourcesBuildPhase *)sourcesBuildPhaseById:(NSString *)uuid;
- (MJPBXVariantGroup *)variantGroupById:(NSString *)uuid;
- (MJPBXContainerItemProxy *)containerItemById:(NSString *)uuid;
- (MJPBXReferenceProxy *)referenceProxyById:(NSString *)uuid;
- (MJPBXTargetDependency *)targetDependencyById:(NSString *)uuid;
- (MJPBXShellScriptBuildPhase *)shellScriptBuildPhaseById:(NSString *)uuid;
- (MJXCBuildConfiguration *)buildConfigurationById:(NSString *)uuid;
- (MJXCConfigurationList *)configurationListById:(NSString *)uuid;

@end
