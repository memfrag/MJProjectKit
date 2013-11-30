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

#import "MJProject.h"
#import "MJPBXBuildFile.h"
#import "MJPBXFileReference.h"
#import "MJPBXFrameworksBuildPhase.h"
#import "MJPBXGroup.h"
#import "MJPBXNativeTarget.h"
#import "MJPBXProject.h"
#import "MJPBXResourcesBuildPhase.h"
#import "MJPBXSourcesBuildPhase.h"
#import "MJPBXVariantGroup.h"
#import "MJPBXContainerItemProxy.h"
#import "MJPBXReferenceProxy.h"
#import "MJPBXTargetDependency.h"
#import "MJPBXShellScriptBuildPhase.h"
#import "MJXCBuildConfiguration.h"
#import "MJXCConfigurationList.h"

@implementation MJProject {
    NSDictionary *_specification;
    
    NSNumber *_archiveVersion;
    NSDictionary *_classes;
    NSNumber *_objectVersion;
    NSDictionary *_objects;
    NSString *_rootObject;
    
    NSMutableDictionary *_allObjects;
    
    NSMutableDictionary *_buildFiles;
    NSMutableArray *_buildFilesArray;
    NSMutableDictionary *_fileReferences;
    NSMutableArray *_fileReferencesArray;
    NSMutableDictionary *_frameworksBuildPhases;
    NSMutableArray *_frameworksBuildPhasesArray;
    NSMutableDictionary *_groups;
    NSMutableArray *_groupsArray;
    NSMutableDictionary *_nativeTargets;
    NSMutableArray *_nativeTargetsArray;
    NSMutableDictionary *_projects;
    NSMutableArray *_projectsArray;
    NSMutableDictionary *_resourcesBuildPhases;
    NSMutableArray *_resourcesBuildPhasesArray;
    NSMutableDictionary *_sourcesBuildPhases;
    NSMutableArray *_sourcesBuildPhasesArray;
    NSMutableDictionary *_variantGroups;
    NSMutableArray *_variantGroupsArray;
    NSMutableDictionary *_containerItemProxies;
    NSMutableArray *_containerItemProxiesArray;
    NSMutableDictionary *_referenceProxies;
    NSMutableArray *_referenceProxiesArray;
    NSMutableDictionary *_targetDependencies;
    NSMutableArray *_targetDependenciesArray;
    NSMutableDictionary *_shellScriptBuildPhases;
    NSMutableArray *_shellScriptBuildPhasesArray;
    NSMutableDictionary *_buildConfigurations;
    NSMutableArray *_buildConfigurationsArray;
    NSMutableDictionary *_configurationLists;
    NSMutableArray *_configurationListsArray;
}

+ (MJProject *)projectWithContentsOfURL:(NSURL *)url
                                  error:(__autoreleasing NSError **)error
{
    MJProject *project = [[MJProject alloc] init];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSDictionary *specification = [NSPropertyListSerialization
                                   propertyListWithData:data
                                                options:NSPropertyListImmutable
                                                 format:NULL
                                                  error:error];
    if (!specification) {
        return nil;
    }
    
    [project setSpecification:specification];
    [project parseSpecification];
    
    return project;
}

- (void)setSpecification:(NSDictionary *)specification
{
    _specification = specification;
}

- (void)parseSpecification
{
    _archiveVersion = [[self.specification objectForKey:@"archiveVersion"] copy];
    _classes = [self.specification objectForKey:@"classes"];
    _objectVersion = [[self.specification objectForKey:@"objectVersion"] copy];
    _objects = [self.specification objectForKey:@"objects"];
    _rootObject = [[self.specification objectForKey:@"rootObject"] copy];
    
    _allObjects = [NSMutableDictionary dictionaryWithCapacity:100];
    
    _buildFiles = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXBuildFile"]) {
            MJPBXBuildFile *buildFile = [[MJPBXBuildFile alloc] init];
            buildFile.uuid = uuid;
            buildFile.project = self;
            buildFile.fileRef = [object objectForKey:@"fileRef"];
            [_buildFiles setObject:buildFile forKey:uuid];
            [_buildFilesArray addObject:buildFile];
            [_allObjects setObject:buildFile forKey:uuid];
        }
    }
    
    _fileReferences = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXFileReference"]) {
            MJPBXFileReference *fileReference = [[MJPBXFileReference alloc] init];
            fileReference.uuid = uuid;
            fileReference.project = self;
            fileReference.explicitFileType = [object objectForKey:@"explicitFileType"];
            fileReference.includeInIndex = [object objectForKey:@"includeInIndex"];
            fileReference.lastKnownFileType = [object objectForKey:@"lastKnownFileType"];
            fileReference.name = [object objectForKey:@"name"];
            fileReference.path = [object objectForKey:@"path"];
            fileReference.sourceTree = [object objectForKey:@"sourceTree"];
            if (!fileReference.name) {
                if (fileReference.path) {
                    fileReference.name = fileReference.path;
                } else {
                    fileReference.name = @"<Unknown File>";
                }
            }
            [_fileReferences setObject:fileReference forKey:uuid];
            [_fileReferencesArray addObject:fileReference];
            [_allObjects setObject:fileReference forKey:uuid];
        }
    }
    
    _frameworksBuildPhases = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXFrameworksBuildPhase"]) {
            MJPBXFrameworksBuildPhase *frameworksBuildPhase = [[MJPBXFrameworksBuildPhase alloc] init];
            frameworksBuildPhase.uuid = uuid;
            frameworksBuildPhase.project = self;
            frameworksBuildPhase.buildActionMask = [object objectForKey:@"buildActionMask"];
            frameworksBuildPhase.files = [object objectForKey:@"files"];
            frameworksBuildPhase.runOnlyForDeploymentPostprocessing = [object objectForKey:@"runOnlyForDeploymentPostProcessing"];
            [_frameworksBuildPhases setObject:frameworksBuildPhase forKey:uuid];
            [_frameworksBuildPhasesArray addObject:frameworksBuildPhase];
            [_allObjects setObject:frameworksBuildPhase forKey:uuid];
        }
    }
    
    _groups = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXGroup"]) {
            MJPBXGroup *group = [[MJPBXGroup alloc] init];
            group.uuid = uuid;
            group.project = self;
            group.children = [object objectForKey:@"children"];
            group.name = [object objectForKey:@"name"];
            group.sourceTree = [object objectForKey:@"sourceTree"];
            group.path = [object objectForKey:@"path"];
            if (!group.name) {
                if (group.path) {
                    group.name = group.path;
                } else {
                    group.name = @"<Unknown Group>";
                }
            }
            [_groups setObject:group forKey:uuid];
            [_groupsArray addObject:group];
            [_allObjects setObject:group forKey:uuid];
        }
    }
    
    _nativeTargets = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXNativeTarget"]) {
            MJPBXNativeTarget *nativeTarget = [[MJPBXNativeTarget alloc] init];
            nativeTarget.uuid = uuid;
            nativeTarget.project = self;
            nativeTarget.buildConfigurationList = [object objectForKey:@"buildConfigurationList"];
            nativeTarget.buildPhases = [object objectForKey:@"buildPhases"];
            nativeTarget.buildRules = [object objectForKey:@"buildRules"];
            nativeTarget.dependencies = [object objectForKey:@"dependencies"];
            nativeTarget.name = [object objectForKey:@"name"];
            nativeTarget.productName = [object objectForKey:@"productName"];
            nativeTarget.productReference = [object objectForKey:@"productReference"];
            nativeTarget.productType = [object objectForKey:@"productType"];
            [_nativeTargets setObject:nativeTarget forKey:uuid];
            [_nativeTargetsArray addObject:nativeTarget];
            [_allObjects setObject:nativeTarget forKey:uuid];
        }
    }
    
    _projects = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXProject"]) {
            MJPBXProject *project = [[MJPBXProject alloc] init];
            project.uuid = uuid;
            project.project = self;
            project.attributes = [object objectForKey:@"attributes"];
            project.buildConfigurationList = [object objectForKey:@"buildConfigurationList"];
            project.compatibilityVersion = [object objectForKey:@"compatibilityVersion"];
            project.developmentRegion = [object objectForKey:@"developmentRegion"];
            project.hasScannedForEncodings = [object objectForKey:@"hasScannedForEncodings"];
            project.knownRegions = [object objectForKey:@"knownRegions"];
            project.mainGroup = [object objectForKey:@"mainGroup"];
            project.projectReferences = [object objectForKey:@"projectReferences"];
            project.productRefGroup = [object objectForKey:@"productRefGroup"];
            project.projectDirPath = [object objectForKey:@"projectDirPath"];
            project.projectRoot = [object objectForKey:@"projectRoot"];
            project.targets = [object objectForKey:@"targets"];
            [_projects setObject:project forKey:uuid];
            [_projectsArray addObject:project];
            [_allObjects setObject:project forKey:uuid];
        }
    }
    
    _resourcesBuildPhases = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXResourcesBuildPhase"]) {
            MJPBXResourcesBuildPhase *resourcesBuildPhase = [[MJPBXResourcesBuildPhase alloc] init];
            resourcesBuildPhase.uuid = uuid;
            resourcesBuildPhase.project = self;
            resourcesBuildPhase.buildActionMask = [object objectForKey:@"buildActionMask"];
            resourcesBuildPhase.files = [object objectForKey:@"files"];
            resourcesBuildPhase.runOnlyForDeploymentPostprocessing = [object objectForKey:@"runOnlyForDeploymentPostprocessing"];
            [_resourcesBuildPhases setObject:resourcesBuildPhase forKey:uuid];
            [_resourcesBuildPhasesArray addObject:resourcesBuildPhase];
            [_allObjects setObject:resourcesBuildPhase forKey:uuid];
        }
    }
    
    _sourcesBuildPhases = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXSourcesBuildPhase"]) {
            MJPBXSourcesBuildPhase *sourcesBuildPhase = [[MJPBXSourcesBuildPhase alloc] init];
            sourcesBuildPhase.uuid = uuid;
            sourcesBuildPhase.project = self;
            sourcesBuildPhase.buildActionMask = [object objectForKey:@"buildActionMask"];
            sourcesBuildPhase.files = [object objectForKey:@"files"];
            sourcesBuildPhase.runOnlyForDeploymentPostprocessing = [object objectForKey:@"runOnlyForDeploymentPostprocessing"];
            [_sourcesBuildPhases setObject:sourcesBuildPhase forKey:uuid];
            [_sourcesBuildPhasesArray addObject:sourcesBuildPhase];
            [_allObjects setObject:sourcesBuildPhase forKey:uuid];
        }
    }
    
    _variantGroups = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXVariantGroup"]) {
            MJPBXVariantGroup *variantGroup = [[MJPBXVariantGroup alloc] init];
            variantGroup.uuid = uuid;
            variantGroup.project = self;
            variantGroup.children = [object objectForKey:@"children"];
            variantGroup.name = [object objectForKey:@"name"];
            variantGroup.sourceTree = [object objectForKey:@"sourceTree"];
            if (!variantGroup.name) {
                variantGroup.name = @"<Unknown Group>";
            }
            [_variantGroups setObject:variantGroup forKey:uuid];
            [_variantGroupsArray addObject:variantGroup];
            [_allObjects setObject:variantGroup forKey:uuid];
        }
    }
    
    _containerItemProxies = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXContainerItemProxy"]) {
            MJPBXContainerItemProxy *containerItemProxy = [[MJPBXContainerItemProxy alloc] init];
            containerItemProxy.uuid = uuid;
            containerItemProxy.project = self;
            containerItemProxy.containerPortal = [object objectForKey:@"containerPortal"];
            containerItemProxy.proxyType = [object objectForKey:@"proxyType"];
            containerItemProxy.remoteGlobalIDString = [object objectForKey:@"remoteGlobalIDString"];
            containerItemProxy.remoteInfo = [object objectForKey:@"remoteInfo"];
            [_containerItemProxies setObject:containerItemProxy forKey:uuid];
            [_containerItemProxiesArray addObject:containerItemProxy];
            [_allObjects setObject:containerItemProxy forKey:uuid];
        }
    }
    
    _targetDependencies = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXTargetDependency"]) {
            MJPBXTargetDependency *targetDependency = [[MJPBXTargetDependency alloc] init];
            targetDependency.uuid = uuid;
            targetDependency.project = self;
            targetDependency.name = [object objectForKey:@"target"];
            targetDependency.targetProxy = [object objectForKey:@"targetProxy"];
            [_targetDependencies setObject:targetDependency forKey:uuid];
            [_targetDependenciesArray addObject:targetDependency];
            [_allObjects setObject:targetDependency forKey:uuid];
        }
    }
    
    _referenceProxies = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXReferenceProxy"]) {
            MJPBXReferenceProxy *referenceProxy = [[MJPBXReferenceProxy alloc] init];
            referenceProxy.uuid = uuid;
            referenceProxy.project = self;
            referenceProxy.fileType = [object objectForKey:@"fileType"];
            referenceProxy.path = [object objectForKey:@"path"];
            referenceProxy.remoteRef = [object objectForKey:@"remoteRef"];
            referenceProxy.sourceTree = [object objectForKey:@"sourceTree"];
            [_referenceProxies setObject:referenceProxy forKey:uuid];
            [_referenceProxiesArray addObject:referenceProxy];
            [_allObjects setObject:referenceProxy forKey:uuid];
        }
    }
    
    _shellScriptBuildPhases = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"PBXShellScriptBuildPhase"]) {
            MJPBXShellScriptBuildPhase *shellScriptBuildPhase = [[MJPBXShellScriptBuildPhase alloc] init];
            shellScriptBuildPhase.uuid = uuid;
            shellScriptBuildPhase.project = self;
            shellScriptBuildPhase.buildActionMask = [object objectForKey:@"buildActionMask"];
            shellScriptBuildPhase.comments = [object objectForKey:@"comments"];
            shellScriptBuildPhase.files = [object objectForKey:@"files"];
            shellScriptBuildPhase.inputPaths = [object objectForKey:@"inputPaths"];
            shellScriptBuildPhase.outputPaths = [object objectForKey:@"outputPaths"];
            shellScriptBuildPhase.runOnlyForDeploymentPostprocessing = [object objectForKey:@"runOnlyForDeploymentPostprocessing"];
            shellScriptBuildPhase.shellPath = [object objectForKey:@"shellPath"];
            shellScriptBuildPhase.shellScript = [object objectForKey:@"shellScript"];
            [_shellScriptBuildPhases setObject:shellScriptBuildPhase forKey:uuid];
            [_shellScriptBuildPhasesArray addObject:shellScriptBuildPhase];
            [_allObjects setObject:shellScriptBuildPhase forKey:uuid];
        }
    }
    
    _buildConfigurations = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"XCBuildConfiguration"]) {
            MJXCBuildConfiguration *buildConfiguration = [[MJXCBuildConfiguration alloc] init];
            buildConfiguration.uuid = uuid;
            buildConfiguration.project = self;
            buildConfiguration.buildSettings = [object objectForKey:@"buildSettings"];
            buildConfiguration.name = [object objectForKey:@"name"];
            [_buildConfigurations setObject:buildConfiguration forKey:uuid];
            [_buildConfigurationsArray addObject:buildConfiguration];
            [_allObjects setObject:buildConfiguration forKey:uuid];
        }
    }
    
    _configurationLists = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *uuid in [self.objects allKeys]) {
        NSDictionary *object = [self.objects objectForKey:uuid];
        NSString *objectIsA = [object objectForKey:@"isa"];
        if ([objectIsA isEqualToString:@"XCConfigurationList"]) {
            MJXCConfigurationList *configurationList = [[MJXCConfigurationList alloc] init];
            configurationList.uuid = uuid;
            configurationList.project = self;
            configurationList.buildConfigurations = [object objectForKey:@"buildConfigurations"];
            configurationList.defaultConfigurationIsVisible = [object objectForKey:@"defaultConfigurationIsVisible"];
            configurationList.defaultConfigurationName = [object objectForKey:@"defaultConfigurationName"];
            [_configurationLists setObject:configurationList forKey:uuid];
            [_configurationListsArray addObject:configurationList];
            [_allObjects setObject:configurationList forKey:uuid];
        }
    }
    
}


- (NSDictionary *)specification
{
    return _specification;
}

- (NSNumber *)archiveVersion
{
    return [_archiveVersion copy];
}

- (NSDictionary *)classes
{
    return _classes;
}

- (NSNumber *)objectVersion
{
    return [_objectVersion copy];
}

- (NSDictionary *)objects
{
    return _objects;
}

- (NSString *)rootObject
{
    return [_rootObject copy];
}

- (NSDictionary *)allObjects
{
    return _allObjects;
}

- (NSArray *)buildFiles
{
    return _buildFilesArray;
}

- (NSArray *)fileReferences
{
    return _fileReferencesArray;
}

- (NSArray *)frameworksBuildPhases
{
    return _frameworksBuildPhasesArray;
}

- (NSArray *)groups
{
    return _groupsArray;
}

- (NSArray *)nativeTargets
{
    return _nativeTargetsArray;
}

- (NSArray *)projects
{
    return _projectsArray;
}

- (NSArray *)resourcesBuildPhases
{
    return _resourcesBuildPhasesArray;
}

- (NSArray *)sourcesBuildPhases
{
    return _sourcesBuildPhasesArray;
}

- (NSArray *)variantGroups
{
    return _variantGroupsArray;
}

- (NSArray *)containerItemProxies
{
    return _containerItemProxiesArray;
}

- (NSArray *)referenceProxies
{
    return _referenceProxiesArray;
}

- (NSArray *)targetDependencies
{
    return _targetDependenciesArray;
}

- (NSArray *)shellScriptBuildPhases
{
    return _shellScriptBuildPhasesArray;
}

- (NSArray *)buildConfigurations
{
    return _buildConfigurationsArray;
}

- (NSArray *)configurationLists
{
    return _configurationListsArray;
}

- (MJPBXBuildFile *)buildFileById:(NSString *)uuid
{
    return [_buildFiles objectForKey:uuid];
}

- (MJPBXFileReference *)fileReferenceById:(NSString *)uuid
{
    return [_fileReferences objectForKey:uuid];
}

- (MJPBXFrameworksBuildPhase *)frameworksBuildPhaseById:(NSString *)uuid
{
    return [_frameworksBuildPhases objectForKey:uuid];
}

- (MJPBXGroup *)groupById:(NSString *)uuid
{
    return [_groups objectForKey:uuid];
}

- (MJPBXNativeTarget *)nativeTargetById:(NSString *)uuid
{
    return [_nativeTargets objectForKey:uuid];
}

- (MJPBXProject *)projectById:(NSString *)uuid
{
    return [_projects objectForKey:uuid];
}

- (MJPBXResourcesBuildPhase *)resourcesBuildPhaseById:(NSString *)uuid
{
    return [_resourcesBuildPhases objectForKey:uuid];
}

- (MJPBXSourcesBuildPhase *)sourcesBuildPhaseById:(NSString *)uuid
{
    return [_sourcesBuildPhases objectForKey:uuid];
}

- (MJPBXVariantGroup *)variantGroupById:(NSString *)uuid
{
    return [_variantGroups objectForKey:uuid];
}

- (MJPBXContainerItemProxy *)containerItemById:(NSString *)uuid
{
    return [_containerItemProxies objectForKey:uuid];
}

- (MJPBXReferenceProxy *)referenceProxyById:(NSString *)uuid
{
    return [_referenceProxies objectForKey:uuid];
}

- (MJPBXTargetDependency *)targetDependencyById:(NSString *)uuid
{
    return [_targetDependencies objectForKey:uuid];
}

- (MJPBXShellScriptBuildPhase *)shellScriptBuildPhaseById:(NSString *)uuid
{
    return [_shellScriptBuildPhases objectForKey:uuid];
}

- (MJXCBuildConfiguration *)buildConfigurationById:(NSString *)uuid
{
    return [_buildConfigurations objectForKey:uuid];
}

- (MJXCConfigurationList *)configurationListById:(NSString *)uuid
{
    return [_configurationLists objectForKey:uuid];
}

@end
