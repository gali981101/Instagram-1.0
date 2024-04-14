//
//  MainTabVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/11.
//

import UIKit
import Firebase
import YPImagePicker

final class MainTabVC: UITabBarController {
}

// MARK: - Life Cycle

extension MainTabVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configViewControllers()
        checkUserIsLoggedIn()
    }
    
}

// MARK: - Service

extension MainTabVC {
    
    private func checkUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let vc = LoginVC()
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                
                self.present(nav, animated: true)
            }
        }
    }
    
}

// MARK: - Set

extension MainTabVC {
    
    private func configViewControllers() {
        self.delegate = self
        
        view.backgroundColor = .systemBackground
        
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = .label
        
        let feedLayout = UICollectionViewFlowLayout()
        
        let feedVC = buildNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.house)!,
            selectedImage: UIImage(systemName: K.SystemImageName.houseFill)!,
            rootVC: FeedVC(collectionViewLayout: feedLayout)
        )
        
        let searchVC = buildNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.magglass)!,
            selectedImage: UIImage(systemName: K.SystemImageName.magglass)!,
            rootVC: SearchVC()
        )
        
        let imageSelectorVC = buildNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.plusapp)!,
            selectedImage: UIImage(systemName: K.SystemImageName.plusappFill)!,
            rootVC: ImageSelectorVC()
        )
        
        let notificationVC = buildNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.heart)!,
            selectedImage: UIImage(systemName: K.SystemImageName.heartFill)!,
            rootVC: NotificationVC()
        )
        
        let profileVC = buildNavController(
            unselectedImage: UIImage(systemName: K.SystemImageName.person)!,
            selectedImage: UIImage(systemName: K.SystemImageName.personFill)!,
            rootVC: ProfileVC()
        )
        
        viewControllers = [
            feedVC,
            searchVC,
            imageSelectorVC,
            notificationVC,
            profileVC
        ]
    }
    
}

// MARK: - UploadPostVCDelegate

extension MainTabVC: UploadPostVCDelegate {
    
    func controllerDidDismiss(_ vc: UploadPostVC) {
        selectedIndex = 0
        vc.dismiss(animated: true)
    }
    
}

// MARK: - UITabBarControllerDelegate

extension MainTabVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            var config = YPImagePickerConfiguration()
            
            config.startOnScreen = .library
            config.shouldSaveNewPicturesToAlbum = false
            config.hidesStatusBar = false
            
            config.colors.tintColor = ThemeColor.red3
            config.colors.bottomMenuItemSelectedTextColor = ThemeColor.red3
            
            config.library.maxNumberOfItems = 10
            
            let picker = YPImagePicker(configuration: config)
            picker.modalPresentationStyle = .fullScreen
            
            present(picker, animated: true)
            
            didFinishPickingMedia(picker)
        }
        
        return true
    }
    
}

// MARK: - Helper Methods

extension MainTabVC {
    
    private func buildNavController(unselectedImage: UIImage, selectedImage: UIImage, rootVC: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootVC)
        
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        
        return nav
    }
    
    private func didFinishPickingMedia(_ picker: YPImagePicker) {
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                self.selectedIndex = 0
                picker.dismiss(animated: true)
            } else {
                var photos: [UIImage] = []
                
                for item in items {
                    switch item {
                    case .photo(let photo):
                        photos.append(photo.image)
                    default:
                        break
                    }
                }
                
                picker.dismiss(animated: false) {
                    let uploadPostVC = UploadPostVC(selectedImages: photos)
                    uploadPostVC.delegate = self
                    
                    let nav = UINavigationController(rootViewController: uploadPostVC)
                    nav.modalPresentationStyle = .fullScreen
                    
                    self.present(nav, animated: false)
                }
            }
        }
    }
    
}



