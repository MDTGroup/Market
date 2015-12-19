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
  @NSManaged var sold: Bool
  @NSManaged var user: User
  @NSManaged var vote: Vote
  @NSManaged var voteCounter:Int
  @NSManaged var isDeleted: Bool
  
  private var uploadedFiles = [PFFile]()
  private var progressFiles = [PFFile: Int]()
    
  var iSaveIt: Bool?
  var iVoteIt: Bool?
  
  var totalProgress: Int = 1
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
  
  var functionName:String {
    switch self {
    case .Following:
      return "nfFollowing"
    case .UsersVote:
      return "nfUsersVote"
    case .Newest:
      return "nfNewest"
    }
  }
}

extension Post {
  static func getNewsfeed(type: NewsfeedType, params: [NSObject:AnyObject], callback: PostResultBlock) {
    PFCloud.callFunctionInBackground(type.functionName, withParameters: params) { (responseData, error) -> Void in
      guard error == nil else {
        callback(posts: nil, error: error)
        return
      }
      
      if let posts = responseData as? [Post] {
        callback(posts: posts, error: nil)
      }
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
    post.fetchInBackgroundWithBlock { (fetchedPFObj, error) -> Void in
      print(fetchedPFObj)
      if let postFetched = fetchedPFObj as? Post {
        //print("post ", postFetched)
        postFetched.isDeleted = true
        
        postFetched.saveWithCallbackProgressAndFinish({ (post: Post) -> Void in
          //print(post)
          completion(true, nil)
          }) { (post: Post, percent: Float) -> Void in
            print(percent)
        }
      } else {
        completion(false, error)
      }
    }
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
    static func search(params: [String:AnyObject], callback: PostResultBlock) {
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