//
//  MainViewController.swift
//  Yoyo
//
//  Created by Essam Nabil on 27/07/2017.
//  Copyright © 2017 Lightsome Apps. All rights reserved.
//
import Alamofire
import SDWebImage
import RZTransitions
class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var MovieTable: UITableView!
    var MovieNames:[String] = []
    var MovieTrailer:[String] = []
    var VideoImagesLink:[String] = [String]()
    var MoviesArray:NSArray = NSArray()
    var imageview: UIImageView = UIImageView()
    static var AnimationOnce:Bool = false
    static var LastScrollIndex:Int = 0
    typealias CompletionHandler = (_ success:Bool) -> Void
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    override func viewDidLoad()
    {
        if !MainViewController.AnimationOnce
        {
            MainViewController.AnimationOnce = true
            animation()
        }
        self.MovieTable.separatorColor = UIColor.clear
        if Reachability.isConnectedToNetwork() && !MainViewController.CheckIfFileExists(filename: "Movies.plist")
        {
            // Get Movies method is used to retrieve all movies from the API
            GetMovies(completionHandler: { (success) -> Void in
                if success
                {
                    self.MovieTable?.reloadData()
                }
            })
        }
        else
        {
            // This method is used to retrieve all movies from the file to laod it offline
            self.ReadMoviesFromFile()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.MovieNames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:MovieCell = tableView.dequeueReusableCell(withIdentifier: "LeftGroupCell")! as! MovieCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.MovieLabel.text = self.MovieNames[indexPath.row]
        if !MainViewController.CheckIfFileExists(filename: self.MovieNames[indexPath.row])
        {
            // SDWebImage library is used to retrieve image on asynchronous thread and save the image as NSdata to load it offline
            imageview.sd_setImage(with: URL(string: self.VideoImagesLink[indexPath.row])) { (Image, error, ImageCache, url) in
                if error == nil
                {
                    print("retrieving image from link")
                    if let width = Image?.size.width, let height = Image?.size.height
                    {
                        let rect = CGRect(x: 0, y: 60, width: width, height: height - 120)
                        cell.MoviePicture.image = Image?.crop(rect: rect)
                        let Image = MainViewController.compressImage(image: cell.MoviePicture.image!, compressionQuality: 0.0, append: true)
                        MainViewController.saveDataToFile(filePath: self.MovieNames[indexPath.row], data: Image)
                        URLCache.shared.removeAllCachedResponses()
                    }
                }
            }
        }
        else
        {
            cell.MoviePicture.image = UIImage(data: MainViewController.ReadDataFromFile(filePath: self.MovieNames[indexPath.row]) as Data,scale:1.0)
            URLCache.shared.removeAllCachedResponses()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if self.MoviesArray.count > indexPath.row
        {
            MainViewController.LastScrollIndex = indexPath.row
            MovieDetailsController.MovieDetails = self.MoviesArray[indexPath.row] as! NSDictionary
            print(MovieDetailsController.MovieDetails)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MovieDetails")
            RZTransitionsManager.shared().defaultPresentDismissAnimationController = RZZoomAlphaAnimationController()
            RZTransitionsManager.shared().defaultPushPopAnimationController = RZCardSlideAnimationController()
            self.transitioningDelegate = RZTransitionsManager.shared()
            nextViewController.transitioningDelegate = RZTransitionsManager.shared()
            self.present(nextViewController, animated:true) {}
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 350
    }
    func GetMovies(completionHandler: @escaping CompletionHandler)
    {
        // This method retrieves the movies from the API and runs the callback closure
        let url = "https://api-v2launch.trakt.tv/movies/trending?page=1&limit=50&extended=full,images"
        let headers   = ["trakt-api-version":"2","trakt-api-key":"0e7e55d561c7e688868a5ea7d2c82b17e59fde95fbc2437e809b1449850d4162"]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers) .responseJSON { response in
                    if let result = response.result.value
                    {
                        let JSON = result as! NSArray
                        self.MoviesArray = JSON
                        self.saveArrayToFile(dict: JSON)
                        for Movies in JSON
                        {
                            if let dict = Movies as? NSDictionary
                            {
                                if let Movie = dict["movie"] as? NSDictionary
                                {
                                    if let title = Movie["title"] as? String, let trailer = Movie["trailer"] as? String
                                    {
                                        let ID = trailer.components(separatedBy: "http://youtube.com/watch?v=")
                                        if ID.count > 1
                                        {
                                            self.MovieNames.append(title)
                                            self.MovieTrailer.append(ID[1])
                                            self.VideoImagesLink.append("https://i.ytimg.com/vi/\(ID[1])/hqdefault.jpg")
                                            self.MovieTable?.reloadData()
                                            if self.MovieNames.count > MainViewController.LastScrollIndex
                                            {
                                                let indexPath = NSIndexPath(row: MainViewController.LastScrollIndex, section: 0)
                                                self.MovieTable?.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                                            }
                                            if self.MovieNames.count == JSON.count - 1
                                            {
                                                completionHandler(true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
        }
    }
    func animation()
    {
        //This method is used for the animation
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.view.layer.mask = nil
        })
        let mask = CALayer()
        mask.contents = UIImage(named: "BackButton")?.cgImage
        mask.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mask.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2)
        self.view.layer.mask = mask
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.duration = 2
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        let initalBounds = NSValue(cgRect: mask.bounds)
        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 90, height: 90))
        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 1500, height: 1500))
        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.3, 2]
        mask.add(keyFrameAnimation, forKey: "bounds")
        CATransaction.commit()
    }
    //This method is used to save images as nsdata
    static func saveDataToFile(filePath: String, data: NSData)
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            let path = dir.appendingPathComponent(filePath)
            do
            {
                try data.write(to: path, options: .atomic)
            }
            catch
            {
                //print(error)
            }
        }
    }
    //This method is used to retrieve images from files
    static func ReadDataFromFile(filePath: String) -> NSData
    {
        var data = NSData()
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            let path = dir.appendingPathComponent(filePath)
            do
            {
                data = try NSData(contentsOf: path, options: .mappedIfSafe)
            }
            catch
            {
                //print(error)
            }
        }
        return data
    }
    //This method is used to save dictionary in the file, however, there are multiple ways to enhance this technique such as using other libraries to save data offline
    func saveArrayToFile(dict: NSArray)
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            let path = dir.appendingPathComponent("Movies.plist")
            NSKeyedArchiver.archiveRootObject(dict, toFile: path.path)
        }
    }
    //This method is used to retrieve movie details from files and reload tableview
    func ReadMoviesFromFile()
    {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            let path = dir.appendingPathComponent("Movies.plist")
            if let customDict = NSKeyedUnarchiver.unarchiveObject(withFile: path.path)
            {
                let JSON = customDict as! NSArray
                self.MoviesArray = JSON
                for Movies in JSON
                {
                    if let dict = Movies as? NSDictionary
                    {
                        if let Movie = dict["movie"] as? NSDictionary
                        {
                            if let title = Movie["title"] as? String, let trailer = Movie["trailer"] as? String
                            {
                                let ID = trailer.components(separatedBy: "http://youtube.com/watch?v=")
                                if ID.count > 1
                                {
                                    self.MovieNames.append(title)
                                    self.MovieTrailer.append(ID[1])
                                    self.VideoImagesLink.append("https://i.ytimg.com/vi/\(ID[1])/hqdefault.jpg")
                                    self.MovieTable?.reloadData()
                                    if self.MovieNames.count > MainViewController.LastScrollIndex
                                    {
                                        let indexPath = NSIndexPath(row: MainViewController.LastScrollIndex, section: 0)
                                        self.MovieTable?.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    //This method is used to check if file exists
    static func CheckIfFileExists(filename: String) -> Bool
    {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent(filename)?.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!)
        {
            return true
        }
        else
        {
            return false
        }
    }
    //This method is used to compress images 
    static func compressImage(image:UIImage, compressionQuality: CGFloat, append: Bool) -> NSData
    {
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        var maxHeight : CGFloat = 800.0
        var maxWidth : CGFloat = 400.0
        if !append
        {
            maxHeight = 200.0
            maxWidth = 140.0
        }
        var imgRatio : CGFloat = actualWidth/actualHeight
        let maxRatio : CGFloat = maxWidth/maxHeight
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img!, compressionQuality);
        UIGraphicsEndImageContext();
        return imageData! as NSData
    }
}
