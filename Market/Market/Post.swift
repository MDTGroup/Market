//
//  Post.swift
//  ParseStarterProject-Swift
//
//  Created by Ngo Thanh Tai on 12/10/15.
//  Copyright © 2015 Parse. All rights reserved.
//

//#import <Parse/PFObject+Subclass.h>

import Foundation
import Parse

class Post: PFObject, PFSubclassing {
    
    static func parseClassName() -> String {
        return "Posts"
    }
    
    @NSManaged var medias:[PFFile]
    @NSManaged var title: String
    @NSManaged var price: Double
    @NSManaged var condition: Int
    @NSManaged var descriptionText: String?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var locationName: String?
    @NSManaged var sold: Bool
    @NSManaged var user: User
    @NSManaged var vote: Vote
    @NSManaged var voteCounter:Int
    @NSManaged var isDeleted: Bool
    
    private var uploadedFiles = [PFFile]()
    private var progressFiles = [PFFile: Int]()
    
    var iSaveIt: Bool?
    var iVoteIt: Bool?
    
    var totalProgress: Int = 100
    var currentTotalProgress: Int = 0
    var finishCallback: ((post: Post) -> Void)?
    var progressCallback: ((post: Post, percent: Float) -> Void)?
}

// MARK: Save post with medias progress
extension Post {
    func saveWithCallbackProgressAndFinish(finish: (post: Post) -> Void, progress: (post: Post, percent:Float) -> Void) {
        
        resetUploadVars()
        
        finishCallback = finish
        progressCallback = progress
        
        if let currentUser = User.currentUser() {
            user = currentUser
        }
        
        handleSaveMedias()
    }
    
    func resetUploadVars() {
        uploadedFiles = []
        totalProgress = medias.count * 100
        if totalProgress == 0 {
            totalProgress = 1
        }
        currentTotalProgress = 0
    }
    
    func handleSaveMedias() {
        if medias.count > 0 {
            for fileToSave in medias {
                if let _ = fileToSave.url {
                    self.checkProgress(fileToSave, percent: 100)
                    self.checkUploading(fileToSave)
                } else {
                    fileToSave.saveInBackgroundWithBlock({ (success, error) -> Void in
                        guard error == nil else {
                            print(error)
                            return
                        }
                        self.checkUploading(fileToSave)
                        }) { (percent) -> Void in
                            
                            self.checkProgress(fileToSave, percent: Int(percent))
                            
                    }
                }
            }
        } else {
            saveData()
        }
    }
    
    private func checkUploading(fileUploaded: PFFile) {
        uploadedFiles.append(fileUploaded)
        
        if uploadedFiles.count == medias.count {
            saveData()
        }
    }
    
    func saveData() {
        saveInBackgroundWithBlock({ (success, error) -> Void in
            guard error == nil else {
                print(error)
                return
            }
            self.finishCallback?(post: self)
        })
    }
    
    private func checkProgress(fileToSave: PFFile, percent: Int) -> Void {
        progressFiles[fileToSave] = percent
        
        var totalPercent = 0
        for progress in progressFiles {
            totalPercent += progress.1
        }
        progressCallback?(post: self, percent: Float(totalPercent)/Float(totalProgress))
    }
}


// MARK: Newsfeed
enum NewsfeedType {
    case Following
    case UsersVote
    case Newest
    
    var name:String {
        switch self {
        case .Following:
            return "Following"
        case .UsersVote:
            return "Users' vote"
        case .Newest:
            return "Newest"
        }
    }
}

extension Post {
    static func getNewsfeed(type: NewsfeedType, lastCreatedAt: NSDate?, callback: PostResultBlock) {
        switch type {
        case NewsfeedType.Newest:
            queryForNewestPost(lastCreatedAt, callback: callback)
        case NewsfeedType.Following:
            queryForFollowing(lastCreatedAt, callback: callback)
        case NewsfeedType.UsersVote:
            queryForUsersVote(lastCreatedAt, callback: callback)
        }
    }
    
    static func queryForNewestPost(lastCreatedAt: NSDate?, callback: PostResultBlock) {
        if let query = Post.query() {
            if let lastCreatedAt = lastCreatedAt {
                query.whereKey("createdAt", lessThan: lastCreatedAt)
            }
            query.limit = 8
            query.includeKey("user")
            query.whereKey("sold", equalTo: false)
            query.whereKey("isDeleted", equalTo: false)
            query.orderByDescending("createdAt")
            query.cachePolicy = .NetworkElseCache
            query.findObjectsInBackgroundWithBlock({ (posts, error) -> Void in
                guard error == nil else {
                    callback(posts: nil, error: error)
                    return
                }
                
                if let posts = posts as? [Post] {
                    callback(posts: posts, error: nil)
                }
            })
        }
    }
    
    static func queryForFollowing(lastCreatedAt: NSDate?, callback: PostResultBlock) {
        if let followQuery = Follow.query(), currentUser = User.currentUser() {
            let cachePolicy = PFCachePolicy.NetworkElseCache
            followQuery.selectKeys(["to"])
            followQuery.whereKey("from", equalTo: currentUser)
            followQuery.cachePolicy = cachePolicy
            followQuery.findObjectsInBackgroundWithBlock({ (followings, error) -> Void in
                guard error == nil else {
                    callback(posts: nil, error: error)
                    return
                }
                if let followings = followings as? [Follow] {
                    var users = [User]()
                    for following in followings {
                        users.append(following.to)
                    }
                    
                    if let query = Post.query() {
                        if let lastCreatedAt = lastCreatedAt {
                            query.whereKey("createdAt", lessThan: lastCreatedAt)
                        }
                        query.limit = 8
                        query.includeKey("user")
                        query.whereKey("user", containedIn: users)
                        query.whereKey("sold", equalTo: false)
                        query.whereKey("isDeleted", equalTo: false)
                        query.orderByDescending("createdAt")
                        query.cachePolicy = cachePolicy
                        query.findObjectsInBackgroundWithBlock({ (posts, error) -> Void in
                            guard error == nil else {
                                callback(posts: nil, error: error)
                                return
                            }
                            
                            if let posts = posts as? [Post] {
                                callback(posts: posts, error: nil)
                            }
                        })
                    }
                }
            })
        }
    }
    
    static func queryForUsersVote(lastCreatedAt: NSDate?, callback: PostResultBlock) {
        if let query = Post.query() {
            if let lastCreatedAt = lastCreatedAt {
                query.whereKey("createdAt", lessThan: lastCreatedAt)
            }
            query.limit = 8
            query.includeKey("user")
            query.whereKey("sold", equalTo: false)
            query.whereKey("isDeleted", equalTo: false)
            query.orderByDescending("voteCounter")
            query.cachePolicy = .NetworkElseCache
            query.findObjectsInBackgroundWithBlock({ (posts, error) -> Void in
                guard error == nil else {
                    callback(posts: nil, error: error)
                    return
                }
                
                if let posts = posts as? [Post] {
                    callback(posts: posts, error: nil)
                }
            })
        }
    }
}

// MARK: Vote
extension Post {
    func vote(enable: Bool, callback: PFBooleanResultBlock) {
        guard User.currentUser() != nil else {
            print("Current user is nil")
            return
        }
        var params = [NSObject : AnyObject]()
        params["postId"] = objectId!
        params["enabled"] = enable
        PFCloud.callFunctionInBackground("vote", withParameters: params) { (result, error) -> Void in
            guard error == nil else {
                callback(false, error)
                return
            }
            
            callback(true, error)
            
            self.fetchInBackground()
        }
    }
}

// MARK: Save
extension Post {
    func save(enable: Bool, callback: PFBooleanResultBlock) {
        guard User.currentUser() != nil else {
            print("Current user is nil")
            return
        }
        let currentUser = User.currentUser()!
        if enable {
            currentUser.savedPosts.addObject(self)
        } else {
            currentUser.savedPosts.removeObject(self)
        }
        
        currentUser.saveInBackgroundWithBlock(callback)
    }
}

// MARK: Delete
extension Post {
    static func deletePost(postId: String, completion: PFBooleanResultBlock) {
        let post = Post(withoutDataWithObjectId: postId)
        post.isDeleted = true
        post.saveInBackgroundWithBlock(completion)
    }
}

// MARK: Sold
extension Post {
    static func sold(postId: String, isSold: Bool, completion: PFBooleanResultBlock) {
        let post = Post(withoutDataWithObjectId: postId)
        post.sold = isSold
        post.saveInBackgroundWithBlock(completion)
    }
}

// MARK: Saved/Vote post status
extension Post {
    func savedPostCurrentUser(callback:PFBooleanResultBlock) {
        if let currentUser = User.currentUser() {
            let query = currentUser.savedPosts.query()
            query.whereKey("objectId", equalTo: objectId!)
            query.countObjectsInBackgroundWithBlock({ (numResult, error) -> Void in
                guard error == nil else {
                    print(error)
                    callback(false, error)
                    return
                }
                callback(numResult > 0, nil)
            })
        }
    }
    
    func votedPostCurrentUser(callback:PFBooleanResultBlock) {
        if let currentUser = User.currentUser() {
            let query = currentUser.votedPosts.query()
            query.whereKey("objectId", equalTo: objectId!)
            query.countObjectsInBackgroundWithBlock({ (numResult, error) -> Void in
                guard error == nil else {
                    print(error)
                    callback(false, error)
                    return
                }
                callback(numResult > 0, nil)
            })
        }
    }
}

// MARK: Search
extension Post {
    static func search(text: String, condition: Int, lastCreatedAt: NSDate?, callback: PostResultBlock) {
        var params = [String : AnyObject]()
        params["text"] = text
        params["condition"] = condition
        params["lastCreatedAt"] = lastCreatedAt
        PFCloud.callFunctionInBackground("search", withParameters: params) { (response, error) -> Void in
            guard error == nil else {
                callback(posts: nil, error: error)
                return
            }
            
            if let posts = response as? [Post] {
                callback(posts: posts, error: nil)
            }
        }
    }
}