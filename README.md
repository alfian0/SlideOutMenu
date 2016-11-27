# SlideOutMenu
## How to use
1. Add `pod 'SlideOutMenu'` on podfile
    ```
    pod 'SlideOutMenu'
    ```
2. Import SlideOutMenu
    ```
    import SlideOutMenu
    ```
3. Inherit `ContainerController` on class
    ```
    class RootViewController: ContainerController {
      ...
    }
    ```
4. Create CenterView class
    ```
    import UIKit
    import SlideOutMenu

    class CenterView: UIViewController, ICenterViewController {
      var delegate: ISlideOutMenuDelegate!
    
      override func viewDidLoad() {
        super.viewDidLoad()
        
      }
    }
    ```
5. Implement `ISlideOutMenu` interface
    ```
    extension RootViewController: ISlideOutMenu {
      func setCenterViewController() -> ICenterViewController {
        return CenterView()
      }
    
      func setLeftViewController() -> UIViewController? {
        return UIViewController()
      }
    
      func setRightViewController() -> UIViewController? {
        return nil
      }
    }
    ```
6. Activate with delegate
    ```
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    ```
        
