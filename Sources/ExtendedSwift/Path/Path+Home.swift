//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/10/23.
//

import Foundation

#if os(macOS)

/*
import Collaboration
import OpenDirectory

// Leaving this here for posterity, since this is very interesting code
 
public enum User {
    
    public static let currentUser: Any? = {
        let session = ODSession.default()
        let root = try! ODNode(session: session, name: "/Local/Default")
        let query = try! ODQuery(node: root, forRecordTypes: kODRecordTypeUsers, attribute: nil, matchType: 0, queryValues: nil, returnAttributes: nil, maximumResults: 0)
        let results = try! query.resultsAllowingPartial(false)
        print(results)
        return results
    }()
    
    public static let currentUserIdentity: CBIdentity? = {
        let q = CSIdentityQueryCreateForCurrentUser(kCFAllocatorDefault)?.takeRetainedValue()
        let flag = CSIdentityQueryFlags(kCSIdentityQueryGenerateUpdateEvents)
        guard CSIdentityQueryExecute(q, flag, nil) else { return nil }
        
        let results = CSIdentityQueryCopyResults(q)?.takeRetainedValue() as NSArray?
        guard let rawIdentities = results as? Array<CSIdentity> else { return nil }
        guard let rawIdentity = rawIdentities.first else { return nil }
        guard let rawPOSIXName = CSIdentityGetPosixName(rawIdentity)?.takeRetainedValue() else { return nil }
        
        let name = (rawPOSIXName as NSString) as String
        return CBIdentity(name: name, authority: .local())
    }()
    
}
 */

#endif

extension Path {
    
    public static let home: Self = {
        #if os(macOS)
        let passInfo = getpwuid(getuid())
        if let homeDir = passInfo?.pointee.pw_dir {
            let homePath = String(cString: homeDir)
            return Path(fileSystemPath: homePath)
        }
        #endif
        
        var p = Path(fileSystemPath: NSHomeDirectory())
        if ProcessInfo.processInfo.entitlements.isSandboxed == false {
            return p
        } else {
            // ~/Library/Containers/{bundle id}/Data
            let homeComponents = p.components.dropLast(4)
            return Path(Array(homeComponents))
        }
    }()
    
}
