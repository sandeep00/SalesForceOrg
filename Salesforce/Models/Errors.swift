//
//  Errors.swift
//  Salesforce
//
//  Created by Bindu on 11/28/18.
//  Copyright © 2018 Sandeep. All rights reserved.
//

import Foundation

enum  MakanaRPTError: Error {
    case invalidCred
    case graphQLError
    case createCommentError
    case fetchFeedError
    case deleteError
    case editCommentError
}

extension MakanaRPTError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCred:
            return NSLocalizedString("Invalid UserName or Password.", comment: "")
        case .createCommentError:
            return NSLocalizedString("Could not create comment", comment: "")
        case .fetchFeedError:
            return NSLocalizedString("Failed to fetch feed", comment: "")
        case .deleteError:
            return NSLocalizedString("Failed to delete comment", comment: "")
        case .editCommentError:
            return NSLocalizedString("Failed to edit comment", comment: "")
        default:
            return NSLocalizedString("Unknown Error.", comment: "")
        }
    }
}
