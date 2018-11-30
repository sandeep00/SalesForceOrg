//
//  CommentsModel.swift
//  Salesforce
//
//  Created by Bindu on 11/27/18.
//  Copyright © 2018 Sandeep. All rights reserved.
//

import Foundation

protocol FeedProtocol {
    var comments: [CommentProtocol] { get set }
}

class Feed: FeedProtocol {
    
    var comments = [CommentProtocol]()
    
}

class Comment: CommentProtocol {
    
    var isPublic: Bool = false
    
    var parentId: String = ""
    
    var id: String = ""
    
    var message: String = ""
    
    var children = [CommentProtocol]()
    
    var author: String = ""
    
}

protocol CommentProtocol {
    
    var id: String { get }
    
    var message: String { get }
    
    var children: [CommentProtocol] { get set }
    
    var author: String { get }
    
    var parentId: String { get }
    
    var isPublic: Bool { get }
}


class CommentsModel {
    
    func create(comment: CommentProtocol, completion: @escaping (MakanaRPTError?, CommentProtocol?) -> Void)  {
        
        let createQuery = CreateCommentMutation(message: comment.message, isPublic: comment.isPublic)
        
        apollo.perform(mutation: createQuery) { (result, error) in
            
            if let data = result?.data {
                
                let comment = Comment()
                comment.id = data.createComment.fragments.commentDetails.id
                comment.author = data.createComment.fragments.commentDetails.author.name
                comment.message = data.createComment.fragments.commentDetails.message
                completion(nil, comment)
            }
            
            if let _ = result?.errors {
                completion(.createCommentError, nil)
            }
            
        }
    }
    
    func detail(for id: String, completion: @escaping (MakanaRPTError?, CommentProtocol?) -> Void) {
        
        let detailQuery = CommentDetailQuery(id: id)
        
        apollo.fetch(query: detailQuery, cachePolicy: .fetchIgnoringCacheData, queue: DispatchQueue.main) { (result, error) in
            
            if let data = result?.data,
               let commentInfo = data.comment {
                
                let comment = Comment()
                comment.author = commentInfo.author.name
                comment.id = commentInfo.id
                comment.message = commentInfo.message
                
                guard let children = commentInfo.children else { return }
                
                var replies = [CommentProtocol]()
                
                for child in children {
                    let kid = Comment()
                    kid.id = child.id
                    kid.message = child.message
                    kid.author = child.author.name
                    
                    replies.append(kid)
                }
                
                comment.children = replies
                
                completion(nil, comment)
            }
            
            if let _ = result?.errors {
                completion(.fetchFeedError, nil)
            }
            
        }
    }
    
    func reply(_ text: String, parentId: String, completion: @escaping (MakanaRPTError?, CommentProtocol?) -> Void) {
        
        let replyQuery = CreateCommentMutation(message: text, isPublic: false, parentCommentId: parentId)
        
        apollo.perform(mutation: replyQuery) { (result, error) in
            
            if let data = result?.data {
                let comment = Comment()
                comment.author = data.createComment.fragments.commentDetails.author.name
                comment.id = data.createComment.fragments.commentDetails.id
                comment.message = data.createComment.fragments.commentDetails.message
                completion(nil, comment)
            }
            
            if let _ = result?.errors {
                completion(.createCommentError, nil)
            }
            
        }
    }
    
    func edit(_ text: String, commentId: String, isPublic: Bool, completion: ((MakanaRPTError?, CommentProtocol?) -> Void)? ) {
        
        let editComment = EditCommentMutation(message: text, isPublic: isPublic, commentId: commentId)
        
        apollo.perform(mutation: editComment) { (result, error) in
            
            if let completionBlock = completion {
                if let data = result?.data {
                    let comment = Comment()
                    comment.author = data.editComment.fragments.commentDetails.author.name
                    comment.id = data.editComment.fragments.commentDetails.id
                    comment.message = data.editComment.fragments.commentDetails.message
                    completionBlock(nil, comment)
                }
                
                if let _ = result?.errors {
                    completionBlock(.editCommentError, nil)
                }
            }
        }
    }
    
    func feed(completion: @escaping (MakanaRPTError?, FeedProtocol?) -> Void) {
        
        let fetchFeed = FeedQuery()
        
        apollo.fetch(query: fetchFeed, cachePolicy: .fetchIgnoringCacheData, queue: DispatchQueue.main) { (result, error) in
            
            if let _ = result?.errors {
                completion(.fetchFeedError, nil)
            }
            
            guard let data = result?.data else { return }
            
            let feed = Feed()
            
            for comment in data.feed {
                let temp = Comment()
                temp.id = comment.id
                temp.message = comment.message
                temp.author = comment.author.name
                
                guard let children = comment.children else { return }
                
                var replies = [CommentProtocol]()
                
                for child in children {
                    let reply = Comment()
                    reply.id = child.id
                    reply.message = child.message
                    reply.author = child.author.name
                    replies.append(reply)
                }
                
                temp.children = replies
                
                feed.comments.append(temp)
            }
            
            completion(nil, feed)
        }
    }
    
    func delete(_ id: String, completion: @escaping (MakanaRPTError?, CommentProtocol?) -> Void) {
        
        let deleteQuery = DeleteCommentMutation(id: id)
        
        apollo.perform(mutation: deleteQuery) { (result, error) in
            if let data = result?.data {
                let comment = Comment()
                comment.author = data.deleteComment.fragments.commentDetails.author.name
                comment.id = data.deleteComment.fragments.commentDetails.id
                comment.message = data.deleteComment.fragments.commentDetails.message
                completion(nil, comment)
            }
            
            if let _ = result?.errors {
                completion(.deleteError, nil)
            }
        }
    }
}
