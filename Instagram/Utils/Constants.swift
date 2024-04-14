//
//  Contants.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/13.
//

import Firebase

// MARK: - Firebase Firestore Ref

let COLLECTION_USERS = Firestore.firestore().collection(K.UserProfile.ref)
let COLLECTION_POSTS = Firestore.firestore().collection(K.Stats.posts)
let COLLECTION_FOLLOWERS = Firestore.firestore().collection(K.Stats.followers)
let COLLECTION_FOLLOWING = Firestore.firestore().collection(K.Stats.following)
let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection(K.Stats.notifications)

// MARK: - K

enum K {
    
    static let appName = "Instagram"
    
    // MARK: - Title
    
    enum Title {
        static let editPost = "Edit Post"
        static let likes = "Likes"
        static let comment = "Comments"
        static let explore = "Explore"
        static let uploadPost = "Upload Post"
        static let photoCaption = "Photo Caption"
        static let notifications = "Notifications"
        static let post = "Post"
        static let follower = "Follower"
        static let following = "Following"
    }
    
    // MARK: - VCName
    
    enum VCName {
        static let feed = "FeedVC"
        static let profile = "ProfileFeedVC"
    }
    
    // MARK: - ImageName
    
    enum ImageName {
        static let img1 = "img-1"
        static let img1_2 = "img-1-2"
        static let img1_3 = "img-1-3"
        static let img2 = "img-2"
        static let img2_2 = "img-2-2"
        static let img2_3 = "img-2-3"
        static let img3 = "img-3"
        static let igLogoWhite = "Instagram_logo_white"
        static let plusPhoto = "plus_photo"
    }
    
    // MARK: - SystemImageName
    
    enum SystemImageName {
        static let heart = "heart"
        static let heartFill = "heart.fill"
        static let message = "message"
        static let paperplane = "paperplane"
        static let heartSlash = "heart.slash"
        static let circleSlash = "circle.slash"
        static let eyeSlash = "eye.slash"
        static let pencil = "pencil"
        static let trash = "trash"
        static let house = "house"
        static let houseFill = "house.fill"
        static let magglass = "magnifyingglass"
        static let plusapp = "plus.app"
        static let plusappFill = "plus.app.fill"
        static let person = "person"
        static let personFill = "person.fill"
        static let gridSplit = "squareshape.split.3x3"
        static let gridFill = "square.grid.3x3.fill"
        static let personCircle = "person.crop.circle"
        static let personSquare = "person.crop.square"
        static let personSquareFill = "person.crop.square.fill"
        static let bookmark = "bookmark"
        static let bookmarkFill =  "bookmark.fill"
        static let arrowTurnLeft = "arrow.uturn.left"
        static let chevronLeft = "chevron.left"
    }
    
    // MARK: - Placeholder
    
    enum Placeholder {
        static let email = "Email"
        static let password = "Password"
        static let fullname = "Fullname"
        static let username = "Username"
        static let enterCaption = "Write some.."
        static let enterComment = "Add your comment..."
        static let search = "Search"
    }
    
    // MARK: - buttonAttribute
    
    enum buttonAttribute {
        static let forgotPassword1 = "Forgot your password?  "
        static let forgotPassword2 = "Get help signing in."
        static let dontHaveAccount1 = "Don't have an account?  "
        static let dontHaveAccount2 = "Sign Up"
        static let alreadyHaveAccount1 = "Already have an account?  "
        static let alreadyHaveAccount2 = "Log In"
    }
    
    // MARK: - ButtonTitle
    
    enum ButtonTitle {
        static let logIn = "Log In"
        static let signUp = "Sign Up"
        static let resetPassword = "Reset Password"
        static let logOut = "LogOut"
        static let editProfile = "Edit Profile"
        static let shareProfile = "Share Profile"
        static let follow = "Follow"
        static let following = "Following"
        static let loading = "Loading"
        static let publish = "Send"
    }
    
    // MARK: - FeedCellContent
    
    enum FeedCellContent {
        static let likesLabelText = "1 like"
        static let captionLabelText = "I hear the secrets that you keep."
        static let postTimeLabelText = "3 days ago"
        static let usernameButtonTitle = "Gali"
    }
    
    // MARK: - CellId
    
    enum CellId {
        static let feedCellId = "FeedCell"
        static let commentCellId = "CommentCell"
        static let uploadPostCellId = "UploadPostCellId"
        static let notificationCellId = "NotificationCell"
        static let userCell = "UserCell"
        static let profileCellId = "ProfileCell"
        static let gridCellId = "GridCell"
        static let profileFeedCellId = "ProfileFeedCell"
    }
    
    // MARK: - UserProfile
    
    enum UserProfile {
        static let ref = "users"
        static let email = "email"
        static let fullname = "fullname"
        static let profileImageUrl = "profileImageUrl"
        static let uid = "uid"
        static let username = "username"
        static let userLikes = "user-likes"
    }
    
    // MARK: - Feed
    
    enum Feed {
        static let userFeed = "user-feed"
    }
    
    // MARK: - Follow
    
    enum Follow {
        static let userFollowing = "user-following"
        static let userFollowers = "user-followers"
        static let posts = "posts"
    }
    
    // MARK: - FStorage
    
    enum FStorage {
        static let profile = "profile-images"
        static let posts = "posts-images"
        static let contentType = "image/jpg"
    }
    
    // MARK: - EmailVerify
    
    enum EmailVerify {
        static let signTitle = "Email Verification"
        static let signMessage = "We've just sent a confirmation email to your email address. Please check your inbox and click the verification link in that email to complete the sign up."
        static let logMessage = "You haven't confirmed your email address yet. We sent you a confirmation email wh en you sign up. Please click the verification link in that email. If you need us t o send the confirmation email again, please tap Resend Email."
        static let resend = "Resend email"
        static let resetPasswordSuccess = "We sent a link to your email to reset your password."
    }
    
    // MARK: - Alert
    
    enum Alert {
        static let ok = "OK"
        static let delete = "Delete"
        static let cancel = "Cancel"
        static let signUpError = "Registration Error"
        static let loginError = "Login Error"
        static let deletePost = "Delete Post?"
        static let error = "Error"
        static let success = "Success"
    }
    
    // MARK: - Stats
    
    enum Stats {
        static let posts = "posts"
        static let followers = "followers"
        static let following = "following"
        static let notifications = "notifications"
    }
    
    // MARK: - NotificationName
    
    enum NotificationName {
        static let updateUser = "currentUserInfo"
        static let updatePost = "updatePost"
        static let deletePost = "deletePost"
        static let updateNotify = "updateNotify"
        static let resetCellHeight = "resetCellHeight"
        static let editedPost = "editedPost"
    }
    
    // MARK: - LabelText
    
    enum LabelText {
        static let characterCount = "0/500"
        static let reply = "Reply"
        static let recent = "Recent"
        static let suggested = "Suggested for you"
    }
    
    // MARK: - Post
    
    enum Post {
        static let caption = "caption"
        static let timestamp = "timestamp"
        static let likes = "likes"
        static let imagesURL = "imagesUrl"
        static let ownerUid = "ownerUid"
        static let ownerImageUrl = "ownerImageUrl"
        static let ownerUsername = "ownerUsername"
        static let postId = "postId"
        static let postLikes = "post-likes"
        static let comments = "comments"
    }
    
    // MARK: - Comment
    
    enum Comment {
        static let commentId = "commentId"
        static let uid = "uid"
        static let comment = "comment"
        static let timestamp = "timestamp"
        static let username = "username"
        static let profileImageUrl = "profileImageUrl"
        static let likes = "likes"
        static let replies = "replies"
    }
    
    // MARK: - Notify
    
    enum Notify {
        static let userNotify = "user-notifications"
        static let id = "id"
        static let uid = "uid"
        static let username = "username"
        static let userImageUrl = "userProfileImageUrl"
        static let postId = "postId"
        static let postImageUrl = "postImageUrl"
        static let timestamp = "timestamp"
        static let type = "type"
    }
    
    // MARK: - PostSetting
    
    enum PostSetting {
        static let hideLikeCount = "Hide like count"
        static let turnOffComment = "Turn off commenting"
        static let edit = "Edit"
        static let delete = "Delete"
        static let aboutAccount = "About this account"
        static let notInterest = "Not Interested"
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let tScale = "transform.scale"
        static let pulse = "pulse"
    }
    
}
